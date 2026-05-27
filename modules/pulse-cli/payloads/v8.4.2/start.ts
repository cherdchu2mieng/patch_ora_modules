// @pulse-patch: start_cmd@v8.4.2
import { gh, getItems, graphql } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle } from "../config";

export async function start(masterItemIndex: number) {
  try {
    const ctx = getContext();
    const allItems = await getItems(ctx);

    if (masterItemIndex < 1 || masterItemIndex > allItems.length) {
      console.error(`Item index ${masterItemIndex} out of range (1-${allItems.length})`);
      return;
    }

    const item = allItems[masterItemIndex - 1];
    const assignedOracle = item.oracle;
    const current = getCurrentOracle();

    // 1. Authority Check: Only the assigned Oracle can 'start'
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

    console.log(`🎬 Starting workflow for Master Item #${masterItemIndex}...\n`);
    
    // 3. Get Project Info (Optimized: One call for both ID and Fields)
    const rawData = await gh("project", "view", String(ctx.projectNumber), "--owner", ctx.org, "--format", "json");
    const projectData = JSON.parse(rawData);
    const projectId = projectData.id;
    const fields = projectData.fields;

    // 4. Surgical Updates (Status & Date)
    const statusField = fields.find(f => f.name.toLowerCase() === "status");
    const inProgressOpt = statusField?.options?.find(o => o.name.toLowerCase() === "in progress");
    const startDateField = fields.find(f => f.name.toLowerCase() === "start date");

    const mutations = [];
    if (statusField && inProgressOpt) {
      mutations.push(`updateStatus: updateProjectV2ItemFieldValue(input: { projectId: "${projectId}", itemId: "${item.id}", fieldId: "${statusField.id}", value: { singleSelectOptionId: "${inProgressOpt.id}" } }) { projectV2Item { id } }`);
    }

    if (startDateField && !item["start date"]) {
      const today = new Date().toISOString().split("T")[0];
      mutations.push(`updateDate: updateProjectV2ItemFieldValue(input: { projectId: "${projectId}", itemId: "${item.id}", fieldId: "${startDateField.id}", value: { date: "${today}" } }) { projectV2Item { id } }`);
    }

    if (mutations.length > 0) {
      await graphql(`mutation { ${mutations.join(" ")} }`);
      if (statusField && inProgressOpt) console.log("✅ Status updated to 'In Progress' on Master Board.");
      if (startDateField && !item["start date"]) console.log(`📅 Start Date set to ${new Date().toISOString().split("T")[0]}.`);
    }
  } catch (e: any) {
    if (e.message?.includes("rate limit exceeded")) {
      console.error("❌ GitHub API Rate Limit Exceeded. Please wait a few minutes before trying again.");
    } else {
      console.error("❌ Failed to execute start command:", e.message);
    }
  }
}