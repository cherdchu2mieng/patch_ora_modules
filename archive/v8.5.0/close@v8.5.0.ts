// @pulse-patch: cmd_close_v1@v8.5.0
import { gh, getItems, setFieldOnItem } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle } from "../config";

export async function close(rawId: string | number, opts: { force?: boolean } = {}) {
  console.log("\n  🌊 Pulse CLI Unified Protocol V1 (v8.5.0)");
  console.log("  ✅ Symmetrical Closure Mode\n");

  const ctx = getContext();
  const currentOracle = getCurrentOracle();
  const items = await getItems(ctx);

  const itemIndex = typeof rawId === "string" ? parseInt(rawId.replace("#", "")) : rawId;

  if (isNaN(itemIndex) || itemIndex < 1 || itemIndex > items.length) {
    console.error(`❌ Error: Item index ${itemIndex} out of range (1-${items.length})`);
    return;
  }

  const item = items[itemIndex - 1];

  // 1. Ownership Verification
  if (!opts.force) {
    if (!currentOracle || item.oracle?.toLowerCase() !== currentOracle.toLowerCase()) {
      console.error(`❌ Authority Error: You are '${currentOracle || 'unknown'}', but this task is assigned to '${item.oracle || 'none'}'.`);
      console.log("💡 Use --force if you are the Orchestrator and need to close this task.");
      return;
    }
    console.log(`🛡️  Verified Assigned Oracle: ${item.oracle}`);
  }

  // 2. Status Guard
  if ((item.status || "").toLowerCase() === "new") {
    console.error("❌ Lifecycle Error: Task is in 'New' status. Please 'start' the task before closing.");
    return;
  }

  // 3. Context-Aware Status Mapping
  const finalStatus = ctx.org === "itinfosv" ? "Closed" : "Done";
  console.log(`🏁 Closing task #${itemIndex} as '${finalStatus}'...`);

  try {
    // 4. Update Board Item
    await setFieldOnItem(ctx, item.id, "Status", finalStatus);
    console.log(`  Board: ✅ ${finalStatus}`);

    // 5. Close GitHub Issue
    if (item.url) {
      await gh("issue", "close", item.url);
      console.log(`  GitHub: ✅ Closed issue`);
    }

    console.log(`\n✅ Task successfully closed on Master Board and GitHub.`);
    
    if (item.worktree) {
       console.log(`\n💡 Hint: You can now remove the worktree for this task:`);
       console.log(`   rm -rf ${item.worktree}`);
    }

  } catch (e: any) {
    console.error(`❌ Error during closure: ${e.message}`);
  }
}