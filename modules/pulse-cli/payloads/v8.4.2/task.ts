// @pulse-patch: task_cmd@v8.4.2
import { gh, getItems, ensureLabel, setFieldOnItem } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle, loadConfig } from "../config";

export async function task(masterItemIndex: number): Promise<string | undefined> {
  const ctx = getContext();
  const currentOracle = getCurrentOracle();
  const items = await getItems(ctx);

  if (masterItemIndex < 1 || masterItemIndex > items.length) {
    console.error(`Master item index ${masterItemIndex} out of range (1-${items.length})`);
    return;
  }

  const masterItem = items[masterItemIndex - 1];

  // 1. Gateway Location Gate (CR-006)
  const currentRepo = (require('path').basename(process.cwd()) || "").toLowerCase();
  const cfg = loadConfig();
  const gatewayRepo = cfg.gateway?.repo?.split("/").pop()?.toLowerCase();

  if (gatewayRepo && currentRepo !== gatewayRepo) {
    console.error(`❌ Location Denied: 'pulse task' must be run within the gateway repository '${gatewayRepo}'.`);
    return;
  }

  // 2. Return Flow Logic (Logic A)
  const currentStatus = (masterItem.status || "").toLowerCase();
  if (currentStatus === "returned") {
    const anchor = masterItem.anchor || "";
    if (anchor.startsWith("ITB-#")) {
      const itbId = anchor.split("#")[1];
      const itbCtx = { ...ctx, org: "itinfosv", projectNumber: (ctx.board as any)?.ITB_NUM || ctx.projectNumber }; // Fallback
      
      console.log(`🔄 Closing cycle: Returning task to ITB-#${itbId}...`);
      
      // Search for ITB item by ID (simulated: assuming items from itinfosv can be fetched if permissions allow)
      // For now, using the anchor to identify the remote item.
      const itbItems = await getItems(itbCtx);
      const itbItem = itbItems.find(it => String(it.id).endsWith(itbId) || String((it as any).number) === itbId);

      if (itbItem) {
        await setFieldOnItem(itbCtx, itbItem.id, "Status", "Closed");
        await setFieldOnItem(itbCtx, itbItem.id, "Anchor", `AIB-#${masterItem.number || masterItemIndex}`);
        console.log(`✅ Cycle closed: ITB-#${itbId} status updated to 'Closed'.`);
      } else {
        console.warn(`⚠️ Could not locate matching item on ITB for ID #${itbId}.`);
      }
    }
    return;
  }

  // 3. Broadcast Logic (Logic B)
  if (currentStatus === "broadcast") {
    console.log("📢 Broadcast detected. Creating report on ITB...");
    // In real scenario, this would trigger 'pulse blog' or equivalent
    return;
  }

  // 4. Existing Pull Logic (Fallback)
  if (!currentOracle || masterItem.oracle?.toLowerCase() !== currentOracle.toLowerCase()) {
    console.error(`❌ Error: Item #${masterItemIndex} is assigned to '${masterItem.oracle || 'none'}', not '${currentOracle || 'unknown'}'.`);
    return;
  }

  const searchPattern = `Parent: ${ctx.org}/pulse-oracle#${masterItemIndex}`;
  
  try {
    const existingLocal = await gh("issue", "list", "--repo", `${ctx.org}/${currentRepo}", "--search", `"${searchPattern}"`, "--json", "number");
    const json = JSON.parse(existingLocal);
    if (json.length > 0) {
       const existingId = json[0].number;
       console.log(`ℹ️ Item #${masterItemIndex} already has a local cross-linked issue: #${existingId}`);
       return String(existingId);
    }
  } catch (e) {}

  console.log(`📥 Pulling task: "${masterItem.title}" from Master Board...`);

  const targetRepo = `${ctx.org}/${currentRepo}`;
  await ensureLabel(targetRepo, `oracle:${currentOracle}`);

  const localIssueBody = [
    masterItem.body || "",
    "",
    "---",
    `🔗 **Cross-Link**`,
    `Parent: ${ctx.org}/pulse-oracle#${masterItemIndex}`
  ].join("
");

  const issueUrl = await gh("issue", "create", "--repo", targetRepo, "--title", masterItem.title, "--body", localIssueBody);
  const localIssueId = issueUrl.trim().split("/").pop();
  console.log(`✅ Created local Issue #${localIssueId} in ${targetRepo}`);

  const masterIssueUrl = (masterItem as any).content?.url;
  if (masterIssueUrl) {
    const updateMsg = `✅ Task pulled to local: ${targetRepo}#${localIssueId}`;
    await gh("issue", "comment", masterIssueUrl, "--body", updateMsg);
    console.log(`🔗 Bidirectional link established on Master Board.`);
  }

  return localIssueId;
}
