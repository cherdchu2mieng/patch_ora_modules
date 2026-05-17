#!/bin/bash
# Pulse Patch v7.8 - THE DEFINITIVE MASTER PATCH
# Cumulative: v7.5, v7.6, v7.7 + v7.8 (Orchestrator, Gateway Ingestion, Auth)

if [ -z "$1" ]; then
  echo "Usage: $0 <pulse-cli-path>"
  exit 1
fi

export PULSE_PATH=$(realpath "$1")
echo "🌊 Applying MASTER Patch v7.8 to $PULSE_PATH..."

# 0. RESET TO BASELINE
cd "$PULSE_PATH"
echo "📦 Resetting source to clean baseline..."
git checkout HEAD -- packages/sdk/src/types.ts packages/sdk/src/github.ts packages/cli/src/config.ts packages/cli/src/commands/init.ts packages/cli/src/commands/index.ts packages/cli/src/commands/add.ts packages/cli/src/commands/scan.ts packages/cli/src/pulse.ts

# 1. SDK types.ts & github.ts
python3 - <<'SDK_EOF'
import os
path_t = os.path.join(os.environ['PULSE_PATH'], 'packages/sdk/src/types.ts')
content_t = open(path_t).read()
if 'gateway?:' not in content_t:
    content_t = content_t.replace('projectNumber: number;', 'projectNumber: number;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };\n  orchestrator?: string;')
if 'client?: string;' not in content_t:
    content_t = content_t.replace('priority?: string;', 'priority?: string;\n  client?: string;')
open(path_t, 'w').write(content_t)

path_g = os.path.join(os.environ['PULSE_PATH'], 'packages/sdk/src/github.ts')
content_g = open(path_g).read()
if 'export async function setFieldOnItem' not in content_g:
    content_g = content_g.replace('async function setFieldOnItem', 'export async function setFieldOnItem')
open(path_g, 'w').write(content_g)
SDK_EOF
echo "✓ Patched SDK (Types & GitHub Export)"

# 2. CLI config.ts
python3 - <<'CONFIG_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/config.ts')
content = open(path).read()
if 'orchestrator?: string;' not in content:
    content = content.replace('oracleRepos: Record<string, string>;', 'oracleRepos: Record<string, string>;\n  orchestrator?: string;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };')
if 'orchestrator: cfg.orchestrator' not in content:
    # Match any return object and replace with full v7.8 version
    import re
    content = re.sub(r'return \{ org: cfg\.org, projectNumber: cfg\.projectNumber.*? \};', 
                     'return { org: cfg.org, projectNumber: cfg.projectNumber, gateway: cfg.gateway, orchestrator: cfg.orchestrator };', content)
open(path, 'w').write(content)
CONFIG_EOF
echo "✓ Patched CLI Config"

# 3. CLI init.ts (Standard v7.8)
python3 - <<'INIT_EOF'
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/init.ts')
content = open(path).read()

# Imports & Helpers
if "import * as fs" not in content:
    content = "import * as fs from 'fs';\nimport * as path from 'path';\nimport { homedir } from 'os';\n" + content

if "async function getGHUser" not in content:
    helper = r'''async function getGHUser(): Promise<string> {
  try {
    const { gh } = require("@pulse-oracle/sdk");
    const userJson = await gh("api", "user", "-q", ".login");
    return userJson.trim();
  } catch (e) {
    return "";
  }
}'''
    content = content.replace('export async function init() {', helper + '\n\nexport async function init() {')

# Implementation
init_impl = r'''export async function init() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  try {
    const scopeInput = await ask(rl, "Initialize scope: [U]ser (default) or [O]rg? (u) ");
    const isOrg = (scopeInput.trim().toLowerCase() || 'u') === 'o';
    const orgInput = await ask(rl, isOrg ? "GitHub org: " : "GitHub user (default: current): ");
    const user = await getGHUser();
    const effectiveOrg = orgInput.trim() || (isOrg ? "" : user);
    if (isOrg && !effectiveOrg) {
      console.error("Error: Organization name is required for Org scope.");
      rl.close(); return;
    }
    const numStr = await ask(rl, "Project number: ");
    const projectNumber = parseInt(numStr.trim());
    let orchestrator;
    if (!isOrg) {
      orchestrator = (await ask(rl, "Orchestrator Oracle (e.g. gemi): ")).trim();
    }
    if (!effectiveOrg || isNaN(projectNumber)) {
      console.error("Invalid org or project number.");
      rl.close(); return;
    }
    let gateway;
    if (isOrg) {
      console.log("--- Gateway Configuration (Required for Org Mode) ---");
      const gRepo = await ask(rl, "Gateway Repo (e.g. itinfosv/it49072-oracle): ");
      const gOracle = await ask(rl, "Gateway Oracle (e.g. pegasus): ");
      const gClient = await ask(rl, "Gateway Client (e.g. IT Board Team): ");
      const gPriority = await ask(rl, "Gateway Priority (e.g. P2): ");
      gateway = { repo: gRepo.trim(), oracle: gOracle.trim(), client: gClient.trim(), priority: gPriority.trim() };
    }
    const configDir = path.join(homedir(), '.config', 'pulse');
    if (!fs.existsSync(configDir)) fs.mkdirSync(configDir, { recursive: true });
    const targetFileName = `pulse.config.${effectiveOrg}_${projectNumber}.json`;
    const targetPath = path.join(configDir, targetFileName);
    const localLinkPath = path.join(process.cwd(), 'pulse.config.json');
    if (!fs.existsSync(targetPath)) {
      console.log(`\nNew Fleet detected. Performing discovery scan in ${effectiveOrg}...`);
      const reposJson = await gh("repo", "list", effectiveOrg, "--json", "name", "--limit", "200");
      const repos = JSON.parse(reposJson);
      const oracleNames = repos.filter((r: any) => r.name.toLowerCase().includes("oracle")).map((r: any) => r.name);
      const oracleRepos: any = {};
      for (const name of oracleNames) {
        const defaultKey = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || name.toLowerCase();
        if (isOrg) { oracleRepos[defaultKey] = name; }
        else {
          const action = await ask(rl, `  Include ${defaultKey} (${name})? [y]es, [n]o? (y) `);
          if ((action.trim().toLowerCase() || 'y') === 'y') oracleRepos[defaultKey] = name;
        }
      }
      const config = {
        org: effectiveOrg,
        projectNumber,
        orchestrator: isOrg ? undefined : orchestrator,
        oracleRepos,
        gateway: isOrg ? undefined : gateway,
        routing: {
          label: Object.keys(oracleRepos).sort().map(o => ({ match: [`oracle/${o}`], oracle: o })),
          repo: Object.entries(oracleRepos).reduce((acc: any, [o, r]) => { acc[r] = o; return acc; }, {}),
          keyword: Object.keys(oracleRepos).map(o => ({ match: [], oracle: o })),
          default: "pulse"
        }
      };
      fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + '\n');
      console.log(`Created central config: ${targetPath}`);
    } else {
      console.log(`Found existing central config: ${targetPath}`);
      const config = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
      let changed = false;
      if (!isOrg && gateway) { config.gateway = gateway; changed = true; }
      if (!isOrg && orchestrator) { config.orchestrator = orchestrator; changed = true; }
      if (changed) {
        fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + '\n');
        console.log(`Updated config in: ${targetPath}`);
      }
    }
    const currentDir = path.basename(process.cwd());
    if (currentDir.toLowerCase().endsWith("-oracle")) {
      if (fs.existsSync(localLinkPath)) {
        if (fs.lstatSync(localLinkPath).isSymbolicLink()) fs.unlinkSync(localLinkPath);
        else fs.renameSync(localLinkPath, localLinkPath + ".bak");
      }
      fs.symlinkSync(targetPath, localLinkPath);
      console.log(`\nSuccess: Created symlink for Oracle repo: ${currentDir}`);
      if (isOrg && user) {
        const userConfigPath = path.join(path.dirname(targetPath), `pulse.config.${user}_${projectNumber}.json`);
        if (fs.existsSync(userConfigPath)) {
          console.log(`\n📡 Syncing Gateway Repo to User Config (${user})...`);
          const userConfig = JSON.parse(fs.readFileSync(userConfigPath, 'utf8'));
          userConfig.gateway = gateway;
          fs.writeFileSync(userConfigPath, JSON.stringify(userConfig, null, 2) + '\n');
          console.log(`✓ Updated User Config: ${userConfigPath}`);
        }
      }
    }
  } finally { rl.close(); }
}'''
m = re.search(r'export async function init\(\) \{[\s\S]+?\}\n\}', content)
if m:
    content = content.replace(m.group(0), init_impl)
open(path, 'w').write(content)
INIT_EOF
echo "✓ Patched Init Logic"

# 4. CLI add.ts & commands/index.ts
python3 - <<'ADD_EOF'
import os
path_i = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/index.ts')
content_i = open(path_i).read()
if 'export { keyword }' not in content_i:
    content_i += 'export { keyword } from "./keyword";\n'
open(path_i, 'w').write(content_i)

path_a = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/add.ts')
content_a = open(path_a).read()
if 'setFieldOnItem' not in content_a:
    content_a = content_a.replace('import { gh,', 'import { gh, setFieldOnItem,')
content_a = content_a.replace('if (!targetRepo) targetRepo = `${ctx.org}/pulse-oracle`;', 
                         'if (targetRepo && !targetRepo.includes("/")) targetRepo = `${ctx.org}/${targetRepo}`;\n  if (!targetRepo) targetRepo = `${ctx.org}/pulse-oracle`;')
client_logic = r'''
  if (opts.client) {
    try { await setFieldOnItem(ctx, addedItemId, "Client", opts.client); console.log(`Client: ${opts.client}`); } catch (e) {}
  }
  if (opts.priority) {
    try { await setFieldOnItem(ctx, addedItemId, "Priority", opts.priority); console.log(`Priority: ${opts.priority}`); } catch (e) {}
  }
  if (opts.oracle) {
    try { await setFieldOnItem(ctx, addedItemId, "Oracle", opts.oracle); console.log(`Oracle: ${opts.oracle}`); } catch (e) {}
  }
'''
if 'if (opts.client)' not in content_a:
    content_a = content_a.replace('return addedItemId;', client_logic + '\n  return addedItemId;')
open(path_a, 'w').write(content_a)
ADD_EOF
echo "✓ Patched Add & Command Export"

# 5. CLI keyword.ts (Implementation)
cat << 'K_EOF' > "$PULSE_PATH/packages/cli/src/commands/keyword.ts"
import * as fs from 'fs';
import * as path from 'path';
export async function keyword(args: string[]) {
  const sub = args[0];
  if (sub !== "sync") { console.log("Usage: pulse keyword sync"); return; }
  const localConfigPath = path.join(process.cwd(), 'pulse.config.json');
  if (!fs.existsSync(localConfigPath)) { console.error("Error: No pulse.config.json found."); return; }
  const targetPath = fs.realpathSync(localConfigPath);
  const config = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
  const currentRepo = path.basename(process.cwd());
  const oracleName = config.routing?.repo?.[currentRepo];
  if (!oracleName) { console.error(`Error: Repo '${currentRepo}' not mapped.`); return; }
  console.log(`Syncing keywords for Oracle: ${oracleName}...`);
  const claudePath = path.join(process.cwd(), 'CLAUDE.md');
  if (!fs.existsSync(claudePath)) { console.error("Error: CLAUDE.md not found."); return; }
  const docContent = fs.readFileSync(claudePath, 'utf8');
  let keywords: string[] = [];
  const kwMatch = docContent.match(/\*\*Keywords\*\*:\s*([\s\S]+?)(?=\n\n|\n#|$)/);
  if (kwMatch) {
    const kwLines = kwMatch[1].split('\n');
    for (const line of kwLines) {
      const match = line.match(/^\s*-\s+(?:[^:]+:\s*)?(.+)$/);
      if (match) { keywords.push(...match[1].split(',').map(w => w.trim())); }
    }
  }
  if (keywords.length === 0) { console.warn("Warning: No keywords found."); return; }
  console.log(`Found keywords: ${keywords.join(', ')}`);
  if (!config.routing) config.routing = {};
  if (!config.routing.keyword) config.routing.keyword = [];
  const existingIdx = config.routing.keyword.findIndex((k: any) => k.oracle === oracleName);
  if (existingIdx !== -1) { config.routing.keyword[existingIdx].match = keywords; }
  else { config.routing.keyword.push({ match: keywords, oracle: oracleName }); }
  fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + '\n');
  console.log("Successfully updated config.");
}
K_EOF
echo "✓ Created Keyword Command"

# 6. CLI scan.ts (Gateway Ingestion)
python3 - <<'SCAN_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/scan.ts')
content = open(path).read()
if "if (ctx.gateway) {" not in content:
    sync_logic = r'''  if (ctx.gateway) {
    console.log(`\n  📡 Checking Gateway: ${ctx.gateway.repo}...`);
    try {
      const gatewayOrg = ctx.gateway.repo.split("/")[0];
      const gatewayCtx = { org: gatewayOrg, projectNumber: ctx.projectNumber };
      const gatewayItems = await getItems(gatewayCtx);
      const aiTeamItems = gatewayItems.filter((i: any) => i.client === "AI-TEAM");
      for (const item of aiTeamItems) {
        console.log(`  Syncing: ${item.title}...`);
        const issueUrl = await gh("issue", "create", "--title", item.title, "--body", `Synced from ${ctx.gateway.repo}\n\n${item.body || ""}`);
        const addRes = await gh("project", "item-add", String(ctx.projectNumber), "--owner", ctx.org, "--url", issueUrl.trim(), "--format", "json");
        const addedItemId = JSON.parse(addRes).id;
        if (addedItemId) {
          try { await (require("@pulse-oracle/sdk")).setFieldOnItem(ctx, addedItemId, "Client", "AI-TEAM"); } catch(e) {}
          try { await (require("@pulse-oracle/sdk")).setFieldOnItem(ctx, addedItemId, "Oracle", (ctx as any).orchestrator || "gemi"); } catch(e) {}
        }
        if (item.url) await gh("issue", "close", item.url);
      }
    } catch (e: any) { console.log(`  Gateway sync error: ${e.message}`); }
  }'''
    content = content.replace('const untracked: { repo: string; title: string; url: string }[] = [];', sync_logic + '\n  const untracked: { repo: string; title: string; url: string }[] = [];')
open(path, 'w').write(content)
SCAN_EOF
echo "✓ Patched Scan (Gateway Sync)"

# 7. CLI pulse.ts (Final Assembly)
python3 - <<'PULSE_EOF'
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/pulse.ts')
content = open(path).read()

# Imports & Version
content = content.replace('import { board', 'import { getContext } from \"./config\";\nimport { board')
content = content.replace('Pulse Oracle', 'Pulse Oracle v7.8')

# enforceAuth helper
auth_fn = r'''function enforceAuth() {
  if (getContext().orchestrator && process.env.ORACLE_NAME !== getContext().orchestrator) {
    console.error("Only the designated Orchestrator can perform board management.");
    process.exit(1);
  }
}'''
if "function enforceAuth()" not in content:
    content = content.replace('const [cmd, ...args]', auth_fn + '\n\nconst [cmd, ...args]')

# Advanced Add logic
add_impl = r'''  case "add":
  case "a": {
    let titleIndex = 0;
    let isOrg = args[0] === "org";
    if (isOrg) titleIndex = 1;
    const title = args[titleIndex];
    if (!title || title.startsWith("--")) {
      console.error("Usage: pulse add [org] <title> [body] [--oracle <name>] [--priority <P0-P3>] [--client <name>]");
      process.exit(1);
    }
    let body = parseFlag("--body");
    if (!body && args[titleIndex + 1] && !args[titleIndex + 1].startsWith("--")) { body = args[titleIndex + 1]; }
    const opts: any = { body, oracle: parseFlag("--oracle"), repo: parseFlag("--repo"), type: parseFlag("--type"), priority: parseFlag("--priority"), client: parseFlag("--client"), wt: parseFlag("--wt"), worktree: args.includes("--worktree"), };
    const ctx = getContext();
    if (isOrg) {
      const gateway = (ctx as any).gateway;
      if (gateway) {
        if (!opts.oracle) opts.oracle = gateway.oracle;
        if (!opts.priority) opts.priority = gateway.priority;
        if (!opts.client) opts.client = gateway.client;
        if (!opts.repo) opts.repo = gateway.repo;
      }
    }
    await add(title, opts);
    break;
  }'''

# Replace add block & Authority Check
m = re.search(r'  case "add":\n  case "a": \{[\s\S]+?break;\n  \}', content)
if m: content = content.replace(m.group(0), add_impl)

content = content.replace('case "set":\n  case "s":', 'case "set":\n  case "s":\n    enforceAuth();')
content = content.replace('case "triage":\n  case "tr":', 'case "triage":\n  case "tr":\n    enforceAuth();')

# Link keyword command
if 'case "keyword":' not in content:
    kw_case = r'''  case "keyword":
  case "kw": {
    const { keyword } = require("./commands/index");
    await keyword(args);
    break;
  }
  case "init":'''
    content = content.replace('case "init":', kw_case)

open(path, 'w').write(content)
PULSE_EOF
echo "✓ Patched CLI Entry (pulse.ts)"

echo "✅ MASTER Patch v7.8 Applied successfully."
