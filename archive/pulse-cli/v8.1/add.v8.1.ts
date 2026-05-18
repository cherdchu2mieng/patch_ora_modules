import { gh, setFieldOnItem, getIssueTypes, setIssueType, setTextField, ensureLabel } from "@pulse-oracle/sdk";
import type { AddOpts } from "@pulse-oracle/sdk";
import { getContext, getOracleRepos, getCurrentOracle } from "../config";
import { mawWake, mawHey } from "../maw";

export async function add(title: string, opts: AddOpts = {}): Promise<string | undefined> {
  const ctx = getContext();
  
  const currentOracle = getCurrentOracle();
  const isOrchestrator = ctx.orchestrator && currentOracle === ctx.orchestrator;
  const oracleLower = opts.oracle?.toLowerCase();
  
  if (oracleLower && currentOracle === oracleLower) {
    if (!opts.priority) opts.priority = "P0";
    if (!opts.client) opts.client = "Self-Direct";
  }
  
  if (oracleLower && currentOracle !== oracleLower && !isOrchestrator) {
    console.log(`Note: Only oracle '${ctx.orchestrator || 'Orchestrator'}' can perform board assignment. Creating issue only.`);
    opts.oracle = undefined; 
  }

  const oracleDisplay = opts.oracle ? opts.oracle.charAt(0).toUpperCase() + opts.oracle.slice(1).toLowerCase() : undefined;

  let targetRepo = opts.repo;
  // v8.1: Centralized Master Board Authority
  if (!targetRepo) targetRepo = `${ctx.org}/pulse-oracle`;

  // Ensure oracle label exists on target repo
  if (oracleDisplay) {
    await ensureLabel(targetRepo, `oracle:${oracleDisplay}`);
  }

  const issueArgs = [
    "issue", "create", "--repo", targetRepo, "--title", title,
    "--body", opts.body || `Created by Pulse Oracle`,
  ];
  if (oracleDisplay) issueArgs.push("--label", `oracle:${oracleDisplay}`);

  const issueUrl = await gh(...issueArgs);
  console.log(`Created: ${issueUrl}`);

  // Set issue type if specified (may fail on cross-org repos)
  if (opts.type) {
    try {
      const types = await getIssueTypes(ctx);
      const match = types.find(t => t.name.toLowerCase() === opts.type!.toLowerCase());
      if (match) {
        const issueJson = await gh("issue", "view", issueUrl.trim(), "--json", "id");
        const issueNodeId = JSON.parse(issueJson).id;
        await setIssueType(issueNodeId, match.id);
        console.log(`Type: ${match.name}`);
      } else {
        console.log(`Type "${opts.type}" not found. Available: ${types.map(t => t.name).join(", ")}`);
      }
    } catch {
      console.log(`Type: skipped (not available on ${targetRepo})`);
    }
  }

  const addResult = await gh("project", "item-add", String(ctx.projectNumber), "--owner", ctx.org, "--url", issueUrl.trim(), "--format", "json");
  const addedItemId = JSON.parse(addResult).id;
  console.log(`Added to Master Board: "${title}"`);

  // Wake oracle if requested
  if (oracleLower && (opts.wt || opts.worktree)) {
    const issueNum = issueUrl.trim().match(/\/(\d+)\s*$/)?.[1] || "0";
    const keywords = title.toLowerCase().replace(/[^a-z0-9\s]/g, "").split(/\s+/).filter(w => w.length > 2).slice(0, 3).join("-");
    const slug = `${issueNum}-${keywords}`.slice(0, 30).replace(/-$/, "");

    const wtName = opts.wt || slug;
    await setTextField(ctx, addedItemId, "Worktree", wtName);
    console.log(`  Worktree: ${wtName}`);

    const wakeOpts: { task?: string; newWt?: string } = {};
    if (opts.worktree) {
      wakeOpts.newWt = slug;
    } else if (opts.wt) {
      wakeOpts.task = opts.wt;
    }

    const wakeResult = await mawWake(oracleLower, wakeOpts);
    if (wakeResult) {
      const windowQuery = wakeOpts.newWt
        ? `${oracleLower}-${wakeOpts.newWt}`
        : wakeOpts.task
          ? `${oracleLower}-${wakeOpts.task}`
          : oracleLower;
      await new Promise(r => setTimeout(r, 2000));
      const delegationMsg = [
        `Issue: ${issueUrl.trim()}`,
        `Target repo: ${targetRepo}`,
        ``,
        `Steps:`,
        `1. /project incubate ${targetRepo}`,
        `2. /trace and /dig to understand context`,
        `3. /plan before implementing`,
        `4. Implement in YOUR worktree — NEVER commit to ${targetRepo} directly`,
        `5. Create PR, report back on issue: commit hash, files, summary`,
        ``,
        `— Pulse (Oracle AI)`,
      ].join("\n");
      await mawHey(windowQuery, delegationMsg);
      console.log(`  Sent issue to ${windowQuery}`);
    }
  }

  
  if (opts.client) {
    try { await setFieldOnItem(ctx, addedItemId, "Client", opts.client); console.log(`Client: ${opts.client}`); } catch (e) {}
  }
  if (opts.priority) {
    try { await setFieldOnItem(ctx, addedItemId, "Priority", opts.priority); console.log(`Priority: ${opts.priority}`); } catch (e) {}
  }
  if (opts.oracle) {
    try { await setFieldOnItem(ctx, addedItemId, "Oracle", opts.oracle); console.log(`Oracle: ${opts.oracle}`); } catch (e) {}
  }

  return addedItemId;
}
