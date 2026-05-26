import { gh, getItems, getFields, getProjectId, graphql } from "@pulse-oracle/sdk";
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

  // 1. Authority Check
  if (assignedOracle && current && assignedOracle.toLowerCase() !== current.toLowerCase()) {
    console.error(`❌ Authority Denied: This task is assigned to '${assignedOracle}', but you are '${current}'.`);
    return;
  }

  // 2. Status Check (Must be 'New' to start)
  const currentStatus = (item.status || "").toLowerCase();
  if (currentStatus !== "new") {
    console.error(`❌ Error: Task is already in '${item.status || 'unknown'}' state. Only 'New' tasks can be started.`);
    return;
  }

  console.log(`🎬 Starting workflow for Master Item #${masterItemIndex}...`);
  
  const projectId = await getProjectId(ctx);
  const fields = await getFields(ctx);

  // 3. Surgical Status Update
  const statusField = fields.find(f => f.name.toLowerCase() === "status");
  const inProgressOpt = statusField?.options?.find(o => o.name.toLowerCase() === "in progress");

  if (statusField && inProgressOpt) {
    await gh(
      "project", "item-edit", "--project-id", projectId,
      "--id", item.id, "--field-id", statusField.id,
      "--single-select-option-id", inProgressOpt.id
    );
    console.log(`✅ Status updated to 'In Progress' on Master Board.`);
  }

  // 4. Surgical Date Update
  const startDateField = fields.find(f => f.name.toLowerCase() === "start date");
  if (startDateField && !item["start date"]) {
    const today = new Date().toISOString().split("T")[0];
    await graphql(`mutation {
      updateProjectV2ItemFieldValue(input: {
        projectId: "${projectId}",
        itemId: "${item.id}",
        fieldId: "${startDateField.id}",
        value: { date: "${today}" }
      }) { projectV2Item { id } }
    }`);
    console.log(`📅 Start Date set to ${today}.`);
  }
}
