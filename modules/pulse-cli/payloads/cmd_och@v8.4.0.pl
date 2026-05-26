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

    // v8.4.0: Allow Ingress from 'Assigned' or 'New' status for flexibility
    const currentStatus = (item.status || "").toLowerCase();
    if (currentStatus !== "assigned" && currentStatus !== "new") {
      console.error(`❌ Error: Task must be in 'Assigned' or 'New' status (Current: ${item.status}).`);
      return;
    }

    // 2. Target Resolution (CR-004 Optimized)
    // Priority: Parameter > Env Var > pulse.config.json
    const configRepo = (ctx as any).orchestrator?.repo;
    const resolvedTarget = targetRepo || process.env.PULSE_OCH_TARGET || configRepo;
    
    if (!resolvedTarget) {
      console.error("❌ Error: No target repository specified.");
      console.error("💡 Use: pulse och <index> <org/repo> or set 'orchestrator.repo' in pulse.config.json");
      return;
    }

    console.log(`📡 Initiating Direct Ingress to ${resolvedTarget}...`);

    // 3. Cross-board Issue Creation
    const anchor = `ITB-#${masterItemIndex}`;
    const body = [
      item.body || "",
      "",
      "----- ",
      `🔗 **Ingress Anchor**: ${anchor}`,
      `👤 **Requester**: ${current || 'Human'}`
    ].join("\n");

    const issueUrl = await gh("issue", "create", "--repo", resolvedTarget, "--title", item.title, "--body", body);
    const newIssueId = issueUrl.trim().split("/").pop();
    
    console.log(`✅ Created remote Issue #${newIssueId} in ${resolvedTarget}`);

    // 4. Master Board Linkage
    const masterIssueUrl = (item as any).content?.url;
    if (masterIssueUrl) {
      const linkMsg = `✅ Delegated to AI Orchestrator: ${resolvedTarget}#${newIssueId}`;
      await gh("issue", "comment", masterIssueUrl, "--body", linkMsg);
      console.log("🔗 Linked to Master Board.");
    }

  } catch (e: any) {
    if (e.message?.includes("rate limit exceeded")) {
      console.error("❌ GitHub API Rate Limit Exceeded. Please wait a few minutes.");
    } else {
      console.error("❌ Failed to execute och command:", e.message);
    }
  }
}
