import { gh, getItems, setFieldOnItem, setTextField, graphql } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle, loadConfig } from "../config";

export async function chb(rawId: string | number, opts: { delegated?: boolean; returned?: boolean } = {}) {
  console.log("\n  🌊 Pulse CLI Unified Protocol V1 (v8.5.0)");
  console.log("  🔄 Handover Standard Mode\n");

  const cfg = loadConfig();
  const ctx = getContext();
  const currentOracle = getCurrentOracle();
  const items = await getItems(ctx);

  const itemIndex = typeof rawId === "string" ? parseInt(rawId.replace("#", "")) : rawId;
  if (isNaN(itemIndex) || itemIndex < 1 || itemIndex > items.length) {
    console.error(`❌ Error: Item index ${itemIndex} out of range (1-${items.length})`);
    return;
  }

  const item = items[itemIndex - 1];
  const isITB = ctx.org.toLowerCase() === "itinfosv";

  if (opts.delegated) {
    // ITB -> AIB
    if (!isITB) {
      console.error("❌ Context Error: --Delegated can only be used on IT Master Board (itinfosv).");
      return;
    }

    if (!item.oracle) {
      console.error("❌ Authority Error: No Oracle assigned to this task. Use 'pulse set' first.");
      return;
    }

    const targetOracle = item.oracle.toLowerCase();
    console.log(`🔄 Delegating task #${itemIndex} to ${item.oracle}'s board...`);

    // 1. Create Issue in AIB
    const aibRepo = `${targetOracle}/pulse-oracle`;
    const issueArgs = [
      "issue", "create", "--repo", aibRepo, "--title", item.title,
      "--body", `Delegated from ITB-#${itemIndex}\n\nOriginal: ${item.url || '---'}`,
    ];
    const aibIssueUrl = await gh(...issueArgs);
    const aibIssueId = aibIssueUrl.trim().split("/").pop();

    // 2. Add to AIB Board (assuming project number is same or discoverable)
    // For V1 simplicity, we assume the user has configured their own project in peers or we use a convention
    // In this implementation, we will just establish the link first.
    
    // 3. Set Anchors
    await setTextField(ctx, item.id, "Anchor", `AIB-#${aibIssueId}`);
    await setFieldOnItem(ctx, item.id, "Status", "In Progress");

    console.log(`  Source: ITB-#${itemIndex}`);
    console.log(`  Target: AIB-#${aibIssueId}`);
    console.log(`  Action: 🔄 Delegated`);
    console.log(`\n✅ Handover completed. Task is now linked.`);

  } else if (opts.returned) {
    // AIB -> ITB
    if (isITB) {
      console.error("❌ Context Error: --Returned should be used on AI Board Team (User board).");
      return;
    }

    if (!item.anchor || !item.anchor.startsWith("ITB-#")) {
      console.error("❌ Anchor Error: No valid ITB anchor found (e.g. ITB-#123). Cannot return.");
      return;
    }

    const itbId = item.anchor.replace("ITB-#", "");
    console.log(`⬆️  Returning task #${itemIndex} to IT Master Board (ID #${itbId})...`);

    // 1. Update AIB Status
    await setFieldOnItem(ctx, item.id, "Status", "Returned");

    // 2. Update ITB Status (requires switching context)
    const itbCtx = { org: "itinfosv", projectNumber: cfg.projectNumber }; // Simplified assumption
    try {
      const itbItems = await getItems(itbCtx);
      const itbItem = itbItems[parseInt(itbId) - 1];
      if (itbItem) {
        await setFieldOnItem(itbCtx, itbItem.id, "Status", "Done");
        console.log(`  Board (ITB): ✅ Done`);
      }
    } catch (e) {
      console.log("  ⚠️  Could not update ITB board automatically. Please notify Orchestrator.");
    }

    console.log(`  Source: AIB-#${itemIndex}`);
    console.log(`  Target: ITB-#${itbId}`);
    console.log(`  Action: ⬆️  Returned`);
    console.log(`\n✅ Return synchronization completed.`);

  } else {
    console.log("Usage: pulse chb <ID> --Delegated | --Returned");
  }
}
