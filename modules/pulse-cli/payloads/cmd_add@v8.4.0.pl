import { gh, getIssueTypes, setIssueType, setTextField, ensureLabel, setFieldOnItem } from "@pulse-oracle/sdk";
import type { AddOpts } from "@pulse-oracle/sdk";
import { getContext, getOracleRepos, loadConfig } from "../config";
import { mawWake, mawHey } from "../maw";

export async function add(title: string, opts: AddOpts = {}): Promise<string | undefined> {
  try {
    // v8.4.0: Config Pre-check & Default Client
    const configPath = require('path').join(process.cwd(), 'pulse.config.json');
    if (!require('fs').existsSync(configPath)) {
      console.error("❌ Error: pulse.config.json not found in current directory.");
      console.error("💡 Please run 'pulse init' first.");
      process.exit(1);
    }

    const cfg = loadConfig();
    const defaultClient = cfg.org === "itinfosv" ? "Human" : "AI";
    const ctx = getContext();
    const oracleLower = opts.oracle?.toLowerCase();
    const oracleDisplay = opts.oracle ? opts.oracle.charAt(0).toUpperCase() + opts.oracle.slice(1).toLowerCase() : undefined;

    const targetRepo = `${ctx.org}/pulse-oracle`;

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

    const addResult = await gh("project", "item-add", String(ctx.projectNumber), "--owner", ctx.org, "--url", issueUrl.trim(), "--format", "json");
    const addedItemId = JSON.parse(addResult).id;
    console.log(`Added to Master Board: "${title}"`);

    // v8.4.0: Enforce Status=New and Default Client
    await setFieldOnItem(ctx, addedItemId, "Status", "New");
    console.log("Status: New");
    
    const clientValue = opts.client || defaultClient;
    await setFieldOnItem(ctx, addedItemId, "Client", clientValue);
    console.log("Client: " + clientValue);

    return addedItemId;
  } catch (e: any) {
    if (e.message?.includes("rate limit exceeded")) {
      console.error("❌ GitHub API Rate Limit Exceeded. Please wait a few minutes before trying again.");
    } else {
      console.error("❌ Failed to add item:", e.message);
    }
  }
}
