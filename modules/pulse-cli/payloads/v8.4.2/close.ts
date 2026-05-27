// @pulse-patch: close_cmd@v8.4.2
import { gh, getItems, getFields, getProjectId, setFieldOnItem } from "@pulse-oracle/sdk";
import { getContext } from "../config";

export async function close(itemIndex: number) {
  const ctx = getContext();
  const items = await getItems(ctx);

  if (itemIndex < 1 || itemIndex > items.length) {
    console.error(`Item index ${itemIndex} out of range (1-${items.length})`);
    process.exit(1);
  }

  const item = items[itemIndex - 1];

  // 1. Closure Restriction (CR-007)
  const currentStatus = (item.status || "").toLowerCase();
  if (currentStatus === "new") {
    console.error(`❌ Error: Cannot close a 'New' task. Please start or assign the task first.`);
    return;
  }

  // 2. Context-Aware Status (CR-007)
  const isITB = ctx.org === "itinfosv";
  const targetStatus = isITB ? "Closed" : "Done";

  console.log(`🔒 Closing: "${item.title}" (Target Status: ${targetStatus})...`);

  // 3. Update Board Status
  await setFieldOnItem(ctx, item.id, "Status", targetStatus);

  // 4. Close the GH issue if it has one
  const issueUrl = (item as any).content?.url;
  if (issueUrl) {
    try {
      await gh("issue", "close", issueUrl);
      console.log(`  ✅ Closed GitHub issue: ${issueUrl}`);
    } catch { /* draft item or inaccessible */ }
  }

  console.log(`  🏁 Task marked as ${targetStatus}.`);
}
