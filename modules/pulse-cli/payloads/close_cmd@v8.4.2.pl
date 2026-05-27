// @pulse-patch: close_cmd@v8.4.2
import { gh, getItems, getFields, getProjectId, setFieldOnItem } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle } from "../config";

export async function close(itemIndex: number) {
  const ctx = getContext();
  const items = await getItems(ctx);

  if (itemIndex < 1 || itemIndex > items.length) {
    console.error(`Item index ${itemIndex} out of range (1-${items.length})`);
    process.exit(1);
  }

  const item = items[itemIndex - 1];

  // 1. Oracle Authority Gate (CR-007.v1 🛡️)
  const currentOracle = getCurrentOracle();
  const assignedOracle = (item.oracle || "").toLowerCase();
  
  if (assignedOracle && currentOracle !== assignedOracle) {
    console.error(`❌ Authority Error: Only the assigned Oracle '${assignedOracle}' can close this task (Current: ${currentOracle || "unknown"}).`);
    return;
  }

  // 2. Closure Restriction (Sacred 🛡️)
  const currentStatus = (item.status || "").toLowerCase();
  if (currentStatus === "new") {
    console.error(`❌ Error: Cannot close a 'New' task. Please start or assign the task first.`);
    return;
  }

  // 3. Context-Aware Status (Sacred 🛡️)
  const isITB = ctx.org === "itinfosv";
  const targetStatus = isITB ? "Closed" : "Done";

  console.log(`🔒 Closing: "${item.title}" (Target Status: ${targetStatus})...`);

  // 4. Update Board Status
  await setFieldOnItem(ctx, item.id, "Status", targetStatus);

  // 5. Close the GH issue if it has one
  const issueUrl = (item as any).content?.url;
  if (issueUrl) {
    try {
      await gh("issue", "close", issueUrl);
      console.log(`  ✅ Closed GitHub issue: ${issueUrl}`);
    } catch { /* draft item or inaccessible */ }
  }

  console.log(`  🏁 Task marked as ${targetStatus}.`);
}
