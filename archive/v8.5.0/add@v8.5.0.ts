// @pulse-patch: cmd_add_v1@v8.5.0
import { gh, getIssueTypes, setIssueType, setTextField, ensureLabel, setFieldOnItem } from "@pulse-oracle/sdk";
import type { AddOpts } from "@pulse-oracle/sdk";
import { getContext, loadConfig } from "../config";
import { mawWake, mawHey } from "../maw";
import * as path from "path";
import * as fs from "fs";

async function ensureRepo(repo: string) {
  try {
    await gh("repo", "view", repo);
  } catch {
    console.log(`\n⚠️  Repository ${repo} not found. Initiating Self-Healing...`);
    await gh("repo", "create", repo, "--public", "--confirm");
    console.log(`✅ Repository ${repo} created.`);
  }
}

export async function add(title: string, opts: AddOpts = {}): Promise<string | undefined> {
  console.log("\n  🌊 Pulse CLI Unified Protocol V1 (v8.5.0)");
  console.log("  🆕 Task Creation Mode\n");

  const configPath = path.join(process.cwd(), "pulse.config.json");
  if (!fs.existsSync(configPath)) {
    console.error("❌ Error: pulse.config.json not found in current directory.");
    console.error("💡 Please run \"pulse init\" first.");
    process.exit(1);
  }

  const cfg = loadConfig();
  const ctx = getContext();
  const defaultClient = cfg.org === "itinfosv" ? "Human" : "AI";
  
  const oracleLower = opts.oracle?.toLowerCase();
  const oracleDisplay = opts.oracle ? opts.oracle.charAt(0).toUpperCase() + opts.oracle.slice(1).toLowerCase() : undefined;

  const targetRepo = `${ctx.org}/pulse-oracle`;

  // 1. Self-Healing Repo
  await ensureRepo(targetRepo);

  // 2. Ensure oracle label exists
  if (oracleDisplay) {
    await ensureLabel(targetRepo, `oracle:${oracleDisplay}`);
  }

  // 3. Create Issue
  const issueArgs = [
    "issue", "create", "--repo", targetRepo, "--title", title,
    "--body", opts.body || `Created by Pulse Oracle`,
  ];
  if (oracleDisplay) issueArgs.push("--label", `oracle:${oracleDisplay}`);

  const issueUrl = await gh(...issueArgs);
  console.log(`Created: ${issueUrl}`);

  // 4. Set issue type
  if (opts.type) {
    try {
      const types = await getIssueTypes(ctx);
      const match = types.find(t => t.name.toLowerCase() === opts.type!.toLowerCase());
      if (match) {
        const issueJson = await gh("issue", "view", issueUrl.trim(), "--json", "id");
        const issueNodeId = JSON.parse(issueJson).id;
        await setIssueType(issueNodeId, match.id);
        console.log(`Type: ${match.name}`);
      }
    } catch {
      // Skip type if repo doesn't support it
    }
  }

  // 5. Add to Board
  const addResult = await gh("project", "item-add", String(ctx.projectNumber), "--owner", ctx.org, "--url", issueUrl.trim(), "--format", "json");
  const addedItemId = JSON.parse(addResult).id;
  console.log(`Added to Board: "${title}"`);

  // 6. Set Fields (Status=New, Client)
  try {
    await setFieldOnItem(ctx, addedItemId, "Status", "New");
    console.log("Status: New");
    
    const clientValue = opts.client || defaultClient;
    await setFieldOnItem(ctx, addedItemId, "Client", clientValue);
    console.log("Client: " + clientValue);
    
    if (opts.priority) {
      await setFieldOnItem(ctx, addedItemId, "Priority", opts.priority);
      console.log("Priority: " + opts.priority);
    }
  } catch (e) {
    console.log("⚠️ Field sync: partially skipped");
  }

  // 7. Wake oracle if requested
  if (oracleLower && (opts.wt || opts.worktree)) {
    const issueNum = issueUrl.trim().match(/\/(\d+)\s*$/)?.[1] || "0";
    const keywords = title.toLowerCase().replace(/[^a-z0-9\s]/g, "").split(/\s+/).filter(w => w.length > 2).slice(0, 3).join("-");
    const slug = `${issueNum}-${keywords}`.slice(0, 30).replace(/-$/, "");

    const wtName = opts.wt || slug;
    await setTextField(ctx, addedItemId, "Worktree", wtName);
    console.log(`Worktree: ${wtName}`);

    const wakeOpts: { task?: string; newWt?: string } = {};
    if (opts.worktree) wakeOpts.newWt = slug;
    else if (opts.wt) wakeOpts.task = opts.wt;

    const wakeResult = await mawWake(oracleLower, wakeOpts);
    if (wakeResult) {
      const windowQuery = wakeOpts.newWt ? `${oracleLower}-${wakeOpts.newWt}` : (wakeOpts.task ? `${oracleLower}-${wakeOpts.task}` : oracleLower);
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
        `5. Create PR, report back on issue`,
        ``,
        `— Pulse (Oracle AI)`,
      ].join("\n");
      await mawHey(windowQuery, delegationMsg);
      console.log(`Sent to ${windowQuery}`);
    }
  }

  console.log("\n✅ Task added and tracked on Master Board.");
  return addedItemId;
}