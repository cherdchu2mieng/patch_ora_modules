import { gh, getItems, graphql } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle } from "../config";

export async function chb(masterItemIndex: number, opts: { delegated?: boolean, returned?: boolean } = {}) {
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

    // 1. Board Context Detection
    const itbOwner = ctx.board?.ITB?.split("/")[0];
    const aibOwner = ctx.board?.AIB?.split("/")[0];
    const isITB = ctx.org === itbOwner;
    const isAIB = ctx.org === aibOwner;

    // 2. Authority Check
    if (assignedOracle && current && assignedOracle !== current.toLowerCase()) {
      console.error(`❌ Authority Denied: You (${current}) are not the assigned Oracle (${assignedOracle}) for this task.`);
      return;
    }

    // 3. Mode Selection & Execution
    if (opts.delegated) {
      // --- DELEGATION MODE (ITB -> AIB) ---
      if (!isITB) {
        console.error("❌ Error: '--Delegated' flag is strictly for use on the ITB board.");
        return;
      }

      const currentStatus = (item.status || "").toLowerCase();
      if (currentStatus !== "assigned") {
        console.error(`❌ Error: Task must be in 'Assigned' status to delegate (Current: ${item.status}).`);
        return;
      }

      const targetRepo = ctx.board?.AIB;
      if (!targetRepo) { console.error("❌ Error: board.AIB not found in config."); return; }

      console.log(`📡 Delegating task to AIB: ${targetRepo}...`);

      const anchorVal = `ITB-#${masterItemIndex}`;
      const body = [item.body || "", "", "--- ", `🔗 **Anchor**: ${anchorVal}`, `👤 **Requester**: ${current || 'Human'}`].join("\n");

      const issueUrl = await gh("issue", "create", "--repo", targetRepo, "--title", item.title, "--body", body);
      const newIssueId = issueUrl.trim().split("/").pop();
      console.log(`✅ Created AIB Issue #${newIssueId}`);

      // Update AIB Board
      try {
        const tParts = targetRepo.split("/");
        const rawFields = await gh("project", "field-list", "1", "--owner", tParts[0], "--format", "json");
        const fields = JSON.parse(rawFields).fields;
        const addRes = await gh("project", "item-add", "1", "--owner", tParts[0], "--url", issueUrl.trim(), "--format", "json");
        const tItemId = JSON.parse(addRes).id;

        const mutations = [];
        const sF = fields.find(f => f.name.toLowerCase() === "status");
        const dOpt = sF?.options?.find(o => o.name.toLowerCase() === "delegated");
        if (sF && dOpt) mutations.push(`uS: updateProjectV2ItemFieldValue(input: { projectId: "PVT_kwHOAYDFrM4BR3DK", itemId: "${tItemId}", fieldId: "${sF.id}", value: { singleSelectOptionId: "${dOpt.id}" } }) { projectV2Item { id } }`);
        
        const cF = fields.find(f => f.name.toLowerCase() === "client");
        const cOpt = cF?.options?.find(o => o.name.toLowerCase() === "human-team");
        if (cF && cOpt) mutations.push(`uC: updateProjectV2ItemFieldValue(input: { projectId: "PVT_kwHOAYDFrM4BR3DK", itemId: "${tItemId}", fieldId: "${cF.id}", value: { singleSelectOptionId: "${cOpt.id}" } }) { projectV2Item { id } }`);

        const aF = fields.find(f => f.name.toLowerCase() === "anchor" || f.name.toLowerCase() === "anchar");
        if (aF) mutations.push(`uA: updateProjectV2ItemFieldValue(input: { projectId: "PVT_kwHOAYDFrM4BR3DK", itemId: "${tItemId}", fieldId: "${aF.id}", value: { text: "${anchorVal}" } }) { projectV2Item { id } }`);

        if (mutations.length > 0) await graphql(`mutation { ${mutations.join(" ")} }`);
        console.log("✅ AIB Board Initialized.");
      } catch (e: any) { console.warn("  ⚠️ AIB update skipped:", e.message); }

      // Update ITB Board (Local)
      const rawLFields = await gh("project", "field-list", String(ctx.projectNumber), "--owner", ctx.org, "--format", "json");
      const lFields = JSON.parse(rawLFields).fields;
      const lProj = await gh("project", "view", String(ctx.projectNumber), "--owner", ctx.org, "--format", "json");
      const lProjId = JSON.parse(lProj).id;

      const lMuts = [];
      const lsF = lFields.find(f => f.name.toLowerCase() === "status");
      const ipOpt = lsF?.options?.find(o => o.name.toLowerCase() === "in progress");
      if (lsF && ipOpt) lMuts.push(`uS: updateProjectV2ItemFieldValue(input: { projectId: "${lProjId}", itemId: "${item.id}", fieldId: "${lsF.id}", value: { singleSelectOptionId: "${ipOpt.id}" } }) { projectV2Item { id } }`);

      const laF = lFields.find(f => f.name.toLowerCase() === "anchor" || f.name.toLowerCase() === "anchar");
      if (laF) lMuts.push(`uA: updateProjectV2ItemFieldValue(input: { projectId: "${lProjId}", itemId: "${item.id}", fieldId: "${laF.id}", value: { text: "AIB-#${newIssueId}" } }) { projectV2Item { id } }`);

      if (lMuts.length > 0) await graphql(`mutation { ${lMuts.join(" ")} }`);
      console.log("✅ ITB Board Updated (In Progress).");

    } else if (opts.returned) {
      // --- RETURN MODE (AIB -> ITB) ---
      if (!isAIB) {
        console.error("❌ Error: '--Returned' flag is strictly for use on the AIB board.");
        return;
      }

      const currentStatus = (item.status || "").toLowerCase();
      if (currentStatus !== "delegated") {
        console.error(`❌ Error: Task must be in 'Delegated' status to return (Current: ${item.status}).`);
        return;
      }

      const anchor = (item as any).anchor || "";
      const itbMatch = anchor.match(/ITB-#(\d+)/);
      if (!itbMatch) {
        console.error("❌ Error: Could not find valid ITB anchor (ITB-#ID) for this task.");
        return;
      }
      const itbIndex = itbMatch[1];
      const targetRepo = ctx.board?.ITB;
      if (!targetRepo) { console.error("❌ Error: board.ITB not found in config."); return; }

      console.log(`📡 Returning task to ITB: ${targetRepo} (#${itbIndex})...`);

      // Update ITB Board (Remote)
      try {
        const tParts = targetRepo.split("/");
        const tProj = await gh("project", "view", "1", "--owner", tParts[0], "--format", "json");
        const tProjId = JSON.parse(tProj).id;
        const rawTFields = await gh("project", "field-list", "1", "--owner", tParts[0], "--format", "json");
        const tFields = JSON.parse(rawTFields).fields;
        const allTItems = await gh("project", "item-list", "1", "--owner", tParts[0], "--format", "json");
        const tItem = JSON.parse(allTItems).items[parseInt(itbIndex) - 1];

        if (tItem) {
          const tSF = tFields.find(f => f.name.toLowerCase() === "status");
          const doneOpt = tSF?.options?.find(o => o.name.toLowerCase() === "done");
          if (tSF && doneOpt) {
            await graphql(`mutation { updateStatus: updateProjectV2ItemFieldValue(input: { projectId: "${tProjId}", itemId: "${tItem.id}", fieldId: "${tSF.id}", value: { singleSelectOptionId: "${doneOpt.id}" } }) { projectV2Item { id } } }`);
            console.log("✅ ITB Board Updated (Status: Done).");
          }
        }
      } catch (e: any) { console.error("❌ Failed to update ITB board:", e.message); return; }

      // Update AIB Board (Local)
      const rawLFields = await gh("project", "field-list", String(ctx.projectNumber), "--owner", ctx.org, "--format", "json");
      const lFields = JSON.parse(rawLFields).fields;
      const lProj = await gh("project", "view", String(ctx.projectNumber), "--owner", ctx.org, "--format", "json");
      const lProjId = JSON.parse(lProj).id;

      const lsF = lFields.find(f => f.name.toLowerCase() === "status");
      const retOpt = lsF?.options?.find(o => o.name.toLowerCase() === "returned");
      if (lsF && retOpt) {
        await graphql(`mutation { updateStatus: updateProjectV2ItemFieldValue(input: { projectId: "${lProjId}", itemId: "${item.id}", fieldId: "${lsF.id}", value: { singleSelectOptionId: "${retOpt.id}" } }) { projectV2Item { id } } }`);
        console.log("✅ AIB Board Updated (Status: Returned).");
      }

    } else {
      console.log("💡 Usage: pulse chb <index> [--Delegated | --Returned]");
    }

  } catch (e: any) {
    if (e.message?.includes("rate limit exceeded")) {
      console.error("❌ GitHub API Rate Limit Exceeded.");
    } else {
      console.error("❌ Failed to execute chb command:", e.message);
    }
  }
}
