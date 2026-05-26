import { gh, getItems, graphql } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle } from "../config";

export async function och(masterItemIndex: number, targetRepo?: string) {
  try {
    const ctx = getContext();
    const allItems = await getItems(ctx);

    if (masterItemIndex < 1 || masterItemIndex > allItems.length) {
      console.error(`Item index ${masterItemIndex} out of range (1-${allItems.length})`);
      return;
    }

    const item = allItems[masterItemIndex - 1];
    const current = getCurrentOracle();
    const assignedOracle = (item.oracle || "").toLowerCase();

    // 1. Authority Check
    if (assignedOracle && current && assignedOracle !== current.toLowerCase()) {
      console.error(`❌ Authority Denied: You (${current}) are not the assigned Oracle (${assignedOracle}) for this task.`);
      return;
    }

    const currentStatus = (item.status || "").toLowerCase();
    if (currentStatus !== "assigned" && currentStatus !== "new") {
      console.error(`❌ Error: Task must be in 'Assigned' or 'New' status (Current: ${item.status}).`);
      return;
    }

    // 2. Target Resolution
    const configRepo = (ctx as any).orchestrator?.repo;
    const resolvedTarget = targetRepo || process.env.PULSE_OCH_TARGET || configRepo;
    
    if (!resolvedTarget) {
      console.error("❌ Error: No target repository specified.");
      return;
    }

    console.log(`📡 Initiating Direct Ingress to ${resolvedTarget}...`);

    // 3. Remote Issue Creation
    const anchorVal = `ITB-#${masterItemIndex}`;
    const body = [
      item.body || "",
      "",
      "----- ",
      `🔗 **Ingress Anchor**: ${anchorVal}`,
      `👤 **Requester**: ${current || 'Human'}`
    ].join("\n");

    const issueUrl = await gh("issue", "create", "--repo", resolvedTarget, "--title", item.title, "--body", body);
    const newIssueId = issueUrl.trim().split("/").pop();
    console.log(`✅ Created remote Issue #${newIssueId} in ${resolvedTarget}`);

    // 4. Remote Board Update (Target Repo's Project #1)
    try {
      const targetParts = resolvedTarget.split("/");
      const targetOwner = targetParts[0];
      const targetProjNum = 1; // Default assumed
      
      const rawTargetData = await gh("project", "view", String(targetProjNum), "--owner", targetOwner, "--format", "json");
      const targetData = JSON.parse(rawTargetData);
      const targetProjectId = targetData.id;
      const targetFields = targetData.fields;

      // Add issue to target board
      const addResult = await gh("project", "item-add", String(targetProjNum), "--owner", targetOwner, "--url", issueUrl.trim(), "--format", "json");
      const targetItemId = JSON.parse(addResult).id;

      const remoteMutations = [];
      
      // 4.1 Status = Delegated
      const statusField = targetFields.find(f => f.name.toLowerCase() === "status");
      const delOpt = statusField?.options?.find(o => o.name.toLowerCase() === "delegated");
      if (statusField && delOpt) {
        remoteMutations.push(`updateStatus: updateProjectV2ItemFieldValue(input: { projectId: "${targetProjectId}", itemId: "${targetItemId}", fieldId: "${statusField.id}", value: { singleSelectOptionId: "${delOpt.id}" } }) { projectV2Item { id } }`);
      }

      // 4.2 Client = Gateway Oracle
      const clientField = targetFields.find(f => f.name.toLowerCase() === "client");
      const gatewayName = (ctx as any).gateway?.oracle;
      const clientOpt = clientField?.options?.find(o => o.name.toLowerCase() === (gatewayName || "").toLowerCase());
      if (clientField && clientOpt) {
        remoteMutations.push(`updateClient: updateProjectV2ItemFieldValue(input: { projectId: "${targetProjectId}", itemId: "${targetItemId}", fieldId: "${clientField.id}", value: { singleSelectOptionId: "${clientOpt.id}" } }) { projectV2Item { id } }`);
      }

      // 4.3 Anchor = ITB-#index
      const anchorField = targetFields.find(f => f.name.toLowerCase() === "anchor" || f.name.toLowerCase() === "anchar");
      if (anchorField) {
        remoteMutations.push(`updateAnchor: updateProjectV2ItemFieldValue(input: { projectId: "${targetProjectId}", itemId: "${targetItemId}", fieldId: "${anchorField.id}", value: { text: "${anchorVal}" } }) { projectV2Item { id } }`);
      }

      if (remoteMutations.length > 0) {
        await graphql(`mutation { ${remoteMutations.join(" ")} }`);
        console.log("✅ Remote board fields initialized (Status: Delegated).");
      }
    } catch (e) {
      console.warn("  ⚠️ Remote board update skipped: Target project #1 not found or fields incompatible.");
    }

    // 5. Local Board Update (Master Board)
    try {
      const rawLocalData = await gh("project", "view", String(ctx.projectNumber), "--owner", ctx.org, "--format", "json");
      const localData = JSON.parse(rawLocalData);
      const localProjectId = localData.id;
      const localFields = localData.fields;

      const localMutations = [];

      // 5.1 Status = In Progress
      const localStatusField = localFields.find(f => f.name.toLowerCase() === "status");
      const ipOpt = localStatusField?.options?.find(o => o.name.toLowerCase() === "in progress");
      if (localStatusField && ipOpt) {
        localMutations.push(`updateStatus: updateProjectV2ItemFieldValue(input: { projectId: "${localProjectId}", itemId: "${item.id}", fieldId: "${localStatusField.id}", value: { singleSelectOptionId: "${ipOpt.id}" } }) { projectV2Item { id } }`);
      }

      // 5.2 Anchor = AIB-#newIssueId
      const localAnchorField = localFields.find(f => f.name.toLowerCase() === "anchor" || f.name.toLowerCase() === "anchar");
      if (localAnchorField) {
        const aibAnchor = `AIB-#${newIssueId}`;
        localMutations.push(`updateAnchor: updateProjectV2ItemFieldValue(input: { projectId: "${localProjectId}", itemId: "${item.id}", fieldId: "${localAnchorField.id}", value: { text: "${aibAnchor}" } }) { projectV2Item { id } }`);
      }

      if (localMutations.length > 0) {
        await graphql(`mutation { ${localMutations.join(" ")} }`);
        console.log("✅ Master board updated (Status: In Progress).");
      }

    } catch (e) {
       console.error("❌ Failed to update local board:", e.message);
    }

  } catch (e: any) {
    if (e.message?.includes("rate limit exceeded")) {
      console.error("❌ GitHub API Rate Limit Exceeded.");
    } else {
      console.error("❌ Failed to execute och command:", e.message);
    }
  }
}
