import { gh, getItems, getFields, getProjectId } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle } from "../config";

export async function start(masterItemIndex: number) {
  const ctx = getContext();
  const allItems = await getItems(ctx);

  if (masterItemIndex < 1 || masterItemIndex > allItems.length) {
    console.error(`Item index ${masterItemIndex} out of range (1-${allItems.length})`);
    return;
  }

  const item = allItems[masterItemIndex - 1];
  const assignedOracle = item.oracle;
  const current = getCurrentOracle();

  if (assignedOracle && current && assignedOracle.toLowerCase() !== current.toLowerCase()) {
    console.error(`❌ Authority Denied: This task is assigned to '${assignedOracle}', but you are '${current}'.`);
    return;
  }

  console.log(`🎬 Starting workflow for Master Item #${masterItemIndex}...`);
  
  // Surgical Status Update (Directly on Master Board)
  const projectId = await getProjectId(ctx);
  const fields = await getFields(ctx);
  const statusField = fields.find(f => f.name === "Status");
  const inProgressOpt = statusField?.options?.find(o => o.name === "In Progress");

  if (statusField && inProgressOpt) {
    await gh(
      "project", "item-edit", "--project-id", projectId,
      "--id", item.id, "--field-id", statusField.id,
      "--single-select-option-id", inProgressOpt.id
    );
    console.log(`✅ Status updated to 'In Progress' on Master Board.`);
  } else {
    console.error("❌ Error: 'Status' field or 'In Progress' option not found on the board.");
  }
}
