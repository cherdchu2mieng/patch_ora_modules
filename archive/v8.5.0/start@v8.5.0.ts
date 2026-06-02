// @pulse-patch: cmd_start_v1@v8.5.0
import { getItems, setFieldOnItem, graphql, getProjectId } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle } from "../config";

export async function start(rawId: string | number, opts: { force?: boolean } = {}) {
  console.log("\n  🌊 Pulse CLI Unified Protocol V1 (v8.5.0)");
  console.log("  ⚡ Lifecycle Activation Mode\n");

  const ctx = getContext();
  const currentOracle = getCurrentOracle();
  const items = await getItems(ctx);
  const projectId = await getProjectId(ctx);

  const itemIndex = typeof rawId === "string" ? parseInt(rawId.replace("#", "")) : rawId;

  if (isNaN(itemIndex) || itemIndex < 1 || itemIndex > items.length) {
    console.error(`❌ Error: Item index ${itemIndex} out of range (1-${items.length})`);
    return;
  }

  const item = items[itemIndex - 1];

  // 1. Identity Gate
  if (!opts.force) {
    if (!currentOracle || item.oracle?.toLowerCase() !== currentOracle.toLowerCase()) {
      console.error(`❌ Authority Error: You are \"${currentOracle || "unknown"}\", but this task is assigned to \"${item.oracle || "none"}\".`);
      console.log("💡 Use --force if you need to start this task anyway.");
      return;
    }
    console.log(`🛡️  Oracle Identity Verified: ${item.oracle}`);
  } else {
    console.log("⚠️  Force Mode: Skipping identity verification.");
  }

  // 2. Surgical Mutation (Status & Start Date)
  const today = new Date().toISOString().split("T")[0];
  console.log(`🚀 Activating task #${itemIndex} on Master Board...`);

  try {
    // Set Status = In Progress
    await setFieldOnItem(ctx, item.id, "Status", "In Progress");
    
    // Set Start Date = Today
    const fieldsRes = await graphql(`{
      node(id: \"${projectId}\") {
        ... on ProjectV2 {
          fields(first: 50) {
            nodes {
              ... on ProjectV2Field { id name }
            }
          }
        }
      }
    }`);
    const fields = fieldsRes.data.node.fields.nodes;

    const startDateField = fields.find((f: any) => f.name === "Start Date");
    if (startDateField) {
      await graphql(`mutation {
        updateProjectV2ItemFieldValue(input: {
          projectId: \"${projectId}\",
          itemId: \"${item.id}\",
          fieldId: \"${startDateField.id}\",
          value: { date: \"${today}\" }
        }) { projectV2Item { id } }
      }`);
    }

    console.log(`\n  Task ID: #${itemIndex}`);
    console.log(`  Status: ⚡ In Progress`);
    console.log(`  Start Date: ${today}`);
    console.log(`\n✅ Task is now active on the Master Board.`);

  } catch (e: any) {
    console.error(`❌ Error updating board: ${e.message}`);
  }
}