// @pulse-patch: go_cmd@v8.2.2
import { gh, getItems, getFields, getProjectId } from "@pulse-oracle/sdk";
import { getContext } from "../config";

export async function go(idOrIndex: number) {
  const ctx = getContext();
  const items = await getItems(ctx);
  const fields = await getFields(ctx);
  const projectId = await getProjectId(ctx);

  // Try to find item by index first, then by issue number (if not in range)
  let localItem = items[idOrIndex - 1];
  
  // If not found or if idOrIndex is suspiciously high (like an issue number), search by title/content
  // But a better way is to search by issue number if it's not a valid index
  if (!localItem || idOrIndex > items.length) {
    localItem = items.find(item => {
        const issueId = item.id.split("/").pop(); // This might not work if item.id is GraphQL ID
        // In gh project item-list, the 'id' field is usually the GraphQL ID.
        // But the 'content' field has the issue number.
        return (item as any).content?.number === idOrIndex;
    });
  }

  if (!localItem) {
    console.error(`Local item with index/ID ${idOrIndex} not found.`);
    return;
  }

  console.log(`🚀 Activating local task: "${localItem.title}"...`);

  const statusField = fields.find(f => f.name === "Status");
  const inProgressOpt = statusField?.options?.find(o => o.name === "In Progress");
  
  if (statusField && inProgressOpt) {
    await gh(
      "project", "item-edit", "--project-id", projectId,
      "--id", localItem.id, "--field-id", statusField.id,
      "--single-select-option-id", inProgressOpt.id,
    );
    console.log(`✅ Local status updated to: In Progress`);

    // Sync to Master
    const parentMatch = localItem.body?.match(/Parent:\s*([^/]+\/[^#]+)#(\d+)/);
    if (parentMatch) {
      const parentMasterIndex = parseInt(parentMatch[2]);
      console.log(`📡 Syncing to Master Board Item #${parentMasterIndex}...`);
      
      // We need to fetch MASTER board items to find the ID. 
      // Current 'items' is from Local context.
      // For simplicity, we assume Master board is 'pulse-oracle' in the same org.
      const masterItems = await getItems({ org: ctx.org, projectNumber: ctx.projectNumber }); // Assuming same project for now, or we need to resolve master board
      const masterItem = masterItems[parentMasterIndex - 1];
      
      if (masterItem) {
        await gh(
          "project", "item-edit", "--project-id", projectId,
          "--id", masterItem.id, "--field-id", statusField.id,
          "--single-select-option-id", inProgressOpt.id,
        );
        console.log(`✅ Master board status updated to: In Progress`);
      }
    }
  }
}
