// @pulse-patch: close_cmd@v8.2.2
import { gh, getItems, getFields, getProjectId } from "@pulse-oracle/sdk";
import { getContext } from "../config";

export async function close(idOrIndex: number) {
  const ctx = getContext();
  const items = await getItems(ctx);
  const fields = await getFields(ctx);
  const projectId = await getProjectId(ctx);

  let localItem = items[idOrIndex - 1];
  if (!localItem || idOrIndex > items.length) {
    localItem = items.find(item => (item as any).content?.number === idOrIndex);
  }

  if (!localItem) {
    console.error(`Local item with index/ID ${idOrIndex} not found.`);
    return;
  }

  console.log(`🏁 Closing task: "${localItem.title}"...`);

  const statusField = fields.find(f => f.name === "Status");
  const doneOpt = statusField?.options?.find(o => o.name === "Done");
  
  if (statusField && doneOpt) {
    // 1. Local Project Update
    await gh(
      "project", "item-edit", "--project-id", projectId,
      "--id", localItem.id, "--field-id", statusField.id,
      "--single-select-option-id", doneOpt.id,
    );
    console.log(`✅ Local project status updated to: Done`);

    // 2. Local Issue Closure
    if ((localItem as any).content?.number) {
        const repo = (localItem as any).content.repository.name;
        await gh("issue", "close", String((localItem as any).content.number), "--repo", `${ctx.org}/${repo}`);
        console.log(`✅ Local issue #${(localItem as any).content.number} closed.`);
    }

    // 3. Master Sync
    const parentMatch = localItem.body?.match(/Parent:\s*([^/]+\/[^#]+)#(\d+)/);
    if (parentMatch) {
      const parentMasterIndex = parseInt(parentMatch[2]);
      console.log(`📡 Syncing to Master Board Item #${parentMasterIndex}...`);
      
      const masterItems = await getItems({ org: ctx.org, projectNumber: ctx.projectNumber });
      const masterItem = masterItems[parentMasterIndex - 1];
      
      if (masterItem) {
        await gh(
          "project", "item-edit", "--project-id", projectId,
          "--id", masterItem.id, "--field-id", statusField.id,
          "--single-select-option-id", doneOpt.id,
        );
        console.log(`✅ Master board status updated to: Done`);
      }
    }
    
    // 4. Cleanup Prompt (Optional - implemented as advice here)
    console.log(`\n💡 Task completed. You can now remove any local worktrees if necessary.`);
  }
}
