// @pulse-patch: task_cmd@v8.2.2
import { gh, getItems, ensureLabel } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle } from "../config";

export async function task(masterItemIndex: number): Promise<string | undefined> {
  const ctx = getContext();
  const currentOracle = getCurrentOracle();
  const items = await getItems(ctx);

  if (masterItemIndex < 1 || masterItemIndex > items.length) {
    console.error(`Master item index ${masterItemIndex} out of range (1-${items.length})`);
    return;
  }

  const masterItem = items[masterItemIndex - 1];
  
  if (!currentOracle || masterItem.oracle?.toLowerCase() !== currentOracle.toLowerCase()) {
    console.error(`❌ Error: Item #${masterItemIndex} is assigned to '${masterItem.oracle || 'none'}', not '${currentOracle || 'unknown'}'.`);
    return;
  }

  const currentRepo = (require('path').basename(process.cwd()) || "").toLowerCase();
  const searchPattern = `Parent: ${ctx.org}/pulse-oracle#${masterItemIndex}`;
  
  try {
    const existingLocal = await gh("issue", "list", "--repo", `${ctx.org}/${currentRepo}`, "--search", `"${searchPattern}"`, "--json", "number");
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
  ].join("\n");

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
