// @pulse-patch: done_cmd@v8.2.1
import { gh, getItems, getFields, getProjectId } from "@pulse-oracle/sdk";
import { getContext } from "../config";

export async function done(localItemIndex: number) {
  const ctx = getContext();
  const items = await getItems(ctx);
  const fields = await getFields(ctx);
  const projectId = await getProjectId(ctx);

  if (localItemIndex < 1 || localItemIndex > items.length) {
    console.error(`Local item index ${localItemIndex} out of range (1-${items.length})`);
    return;
  }

  const localItem = items[localItemIndex - 1];
  console.log(`🏁 Closing local task: "${localItem.title}"...`);

  const statusField = fields.find(f => f.name === "Status");
  const inProgressOpt = statusField?.options?.find(o => o.name === "Done");
  
  if (statusField && inProgressOpt) {
    // Phase 1: Local Item Update on Board
    await gh(
      "project", "item-edit", "--project-id", projectId,
      "--id", localItem.id, "--field-id", statusField.id,
      "--single-select-option-id", inProgressOpt.id,
    );
    console.log(`✅ Local status updated to: Done`);

    // Phase 2: Master Sync (if cross-linked)
    const parentMatch = localItem.body?.match(/Parent:\s*([^/]+\/[^#]+)#(\d+)/);
    if (parentMatch) {
      const parentMasterIndex = parseInt(parentMatch[2]);
      console.log(`📡 Found Cross-Link to Master Board Item #${parentMasterIndex}`);
      
      try {
        const masterItem = items[parentMasterIndex - 1];
        if (masterItem && masterItem.title === localItem.title) {
          await gh(
            "project", "item-edit", "--project-id", projectId,
            "--id", masterItem.id, "--field-id", statusField.id,
            "--single-select-option-id", inProgressOpt.id,
          );
          console.log(`✅ Master board status updated to: Done`);
        }
      } catch (e) {
        console.log(`⚠️ Master sync failed: ${(e as any).message}`);
      }
    }
  }
}
