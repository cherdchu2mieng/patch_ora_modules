#!/bin/bash

# Comprehensive patch for pulse-cli: v7.7 (Dynamic Gateway + Cumulative v7.5/v7.6)

SCRIPT_DIR=$(dirname $(realpath "$0"))
COMMON_SH="$SCRIPT_DIR/../../core/common.sh"
if [ -f "$COMMON_SH" ]; then source "$COMMON_SH"; else exit 1; fi

export PULSE_PATH=$(verify_path "$1")
log_step "🚀 Starting Comprehensive Patch (v7.7) for pulse-cli..."

TARGET_FILES=(
    "packages/sdk/src/types.ts"
    "packages/sdk/src/github.ts"
    "packages/cli/src/config.ts"
    "packages/cli/src/commands/init.ts"
    "packages/cli/src/pulse.ts"
    "packages/cli/src/commands/add.ts"
)

# 0.1 Backup
log_info "Creating backups..."
for f in "${TARGET_FILES[@]}"; do
    [ -f "$PULSE_PATH/$f" ] && cp "$PULSE_PATH/$f" "$PULSE_PATH/$f.v77.bak"
done

# --- 1. Patch packages/sdk/src/types.ts ---
log_step "🛠️ Patching SDK types.ts..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/sdk/src/types.ts')
content = open(path).read()
# Add gateway to PulseContext
if 'gateway?: { repo: string; oracle: string; client: string; priority: string };' not in content:
    content = content.replace('projectNumber: number;', 'projectNumber: number;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };')
# Add client to AddOpts
if 'client?: string;' not in content:
    content = content.replace('priority?: string;', 'priority?: string;\n  client?: string;')
open(path, 'w').write(content)
PY_EOF

# --- 2. Patch packages/sdk/src/github.ts ---
log_step "🛠️ Patching SDK github.ts..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/sdk/src/github.ts')
content = open(path).read()
if 'export async function setFieldOnItem' not in content:
    content = content.replace('async function setFieldOnItem', 'export async function setFieldOnItem')
    open(path, 'w').write(content)
PY_EOF

# --- 3. Patch packages/cli/src/config.ts ---
log_step "🛠️ Patching CLI config.ts..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/config.ts')
content = open(path).read()
# Add to PulseConfig interface
if 'gateway?: {' not in content:
    content = content.replace('oracleRepos: Record<string, string>;', 'oracleRepos: Record<string, string>;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };')
# Update getContext()
if 'gateway: cfg.gateway' not in content:
    content = content.replace('return { org: cfg.org, projectNumber: cfg.projectNumber };', 
                         'return { org: cfg.org, projectNumber: cfg.projectNumber, gateway: cfg.gateway };')
open(path, 'w').write(content)
PY_EOF

# --- 4. Patch packages/cli/src/commands/init.ts ---
log_step "🛠️ Patching CLI init.ts (Scope, Gateway & Cross-Sync)..."
python3 - <<'PY_EOF'
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/init.ts')
content = open(path).read()

# Update imports
if "import * as fs from 'fs';" not in content:
    content = "import * as fs from 'fs';\nimport * as path from 'path';\nimport { homedir } from 'os';\n" + content

# Helper for GH User
if "async function getGHUser()" not in content:
    helper = """
async function getGHUser(): Promise<string> {
  try {
    const { gh } = require("@pulse-oracle/sdk");
    const userJson = await gh("api", "user", "-q", ".login");
    return userJson.trim();
  } catch (e) {
    return "";
  }
}
"""
    content = content.replace('export async function init() {', helper + '\nexport async function init() {')

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
      return;
    }

    const numStr = await ask(rl, "Project number: ");
    const projectNumber = parseInt(numStr.trim());

    if (!effectiveOrg || isNaN(projectNumber)) {
      console.error("Invalid org or project number.");
      return;
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

    // --- Discovery Logic ---
    if (!fs.existsSync(targetPath)) {
      console.log(`\nNew Fleet detected. Performing discovery scan in ${effectiveOrg}...`);
      const reposJson = await gh("repo", "list", effectiveOrg, "--json", "name", "--limit", "200");
      const repos: { name: string }[] = JSON.parse(reposJson);
      const oracleNames = repos
        .filter((r) => r.name.toLowerCase().includes("oracle"))
        .map((r) => r.name);

      const oracleRepos: Record<string, string> = {};
      for (const name of oracleNames) {
        const defaultKey = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || name.toLowerCase();
        if (isOrg) {
          oracleRepos[defaultKey] = name;
        } else {
          const action = await ask(rl, `  Include ${defaultKey} (${name})? [y]es, [n]o? (y) `);
          if ((action.trim().toLowerCase() || 'y') === 'y') {
            oracleRepos[defaultKey] = name;
          }
        }
      }
      if (isOrg) console.log(`  Auto-included ${Object.keys(oracleRepos).length} oracles from Org.`);

      const config: PulseConfig = {
        org: effectiveOrg,
        projectNumber,
        oracleRepos,
        gateway,
        routing: {
          label: Object.keys(oracleRepos).sort().map(o => ({ match: [`oracle/${o}`], oracle: o })),
          repo: Object.entries(oracleRepos).reduce((acc, [o, r]) => { acc[r] = o; return acc; }, {} as any),
          keyword: Object.keys(oracleRepos).map(o => ({ match: [], oracle: o })),
          default: "pulse"
        }
      };
      fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + '\n');
      console.log(`Created central config: ${targetPath}`);
    } else {
      console.log(`Found existing central config: ${targetPath}`);
      if (gateway) {
        const config = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
        config.gateway = gateway;
        fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + '\n');
        console.log(`Updated gateway in: ${targetPath}`);
      }
    }

    // --- Oracle-only Symlinking & Cross-Sync ---
    const currentDir = path.basename(process.cwd());
    if (currentDir.toLowerCase().endsWith("-oracle")) {
      if (fs.existsSync(localLinkPath)) {
          const stats = fs.lstatSync(localLinkPath);
          if (stats.isSymbolicLink()) fs.unlinkSync(localLinkPath);
          else fs.renameSync(localLinkPath, localLinkPath + ".bak");
      }
      fs.symlinkSync(targetPath, localLinkPath);
      console.log(`\nSuccess: Created symlink for Oracle repo: ${currentDir}`);

      // --- Cross-Sync Gateway to User Config ---
      if (isOrg && user) {
        const userConfigPath = path.join(path.dirname(targetPath), `pulse.config.${user}_${projectNumber}.json`);
        if (fs.existsSync(userConfigPath)) {
          console.log(`\n📡 Syncing Gateway Repo to User Config (${user})...`);
          const userConfig = JSON.parse(fs.readFileSync(userConfigPath, 'utf8'));
          const oracleName = currentDir.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || currentDir.toLowerCase();
          
          userConfig.oracleRepos = userConfig.oracleRepos || {};
          userConfig.oracleRepos[oracleName] = currentDir;
          
          if (userConfig.routing && userConfig.routing.repo) {
            userConfig.routing.repo[currentDir] = oracleName;
          }
          
          fs.writeFileSync(userConfigPath, JSON.stringify(userConfig, null, 2) + '\n');
          console.log(`✓ Updated User Config: ${userConfigPath}`);
        }
      }
      console.log(`Run 'pulse keyword sync' next to update keywords.`);
    } else {
      console.log(`\nWarning: Current directory '${currentDir}' is not an Oracle repo. Skipping symlink.`);
    }
  } finally {
    rl.close();
  }
}'''

# Find the start and end of the init function
m_start = re.search(r'export async function init\(\) \{', content)
if m_start:
    # Escape backslashes for re.sub replacement to preserve \n
    init_impl_esc = init_impl.replace('\\', '\\\\')
    content = re.sub(r'export async function init\(\) \{[\s\S]+?rl\.close\(\);\n\s*\}\n\}', init_impl_esc, content)

open(path, 'w').write(content)
PY_EOF

# --- 5. Patch packages/cli/src/pulse.ts ---
log_step "🛠️ Patching CLI pulse.ts (Version, Keyword Link & Advanced Add)..."
python3 - <<'PY_EOF'
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/pulse.ts')
content = open(path).read()

# 5.1 Version indicator
content = re.sub(r'GH Projects Master Board CLI \(patched 🌊 v7\.[0-9]+\)', 'GH Projects Master Board CLI (patched 🌊 v7.7)', content)
content = re.sub(r'pulse — GH Projects Master Board CLI \(patched 🌊 v7\.[0-9]+\)', 'pulse — GH Projects Master Board CLI (patched 🌊 v7.7)', content)

# 5.2 Advanced Add Syntax
add_impl = """  case "add":
  case "a": {
    let titleIndex = 0;
    let isOrg = args[0] === "org";
    if (isOrg) titleIndex = 1;

    const title = args[titleIndex];
    if (!title || title.startsWith("--")) {
      console.error("Usage: pulse add [org] <title> [body] [--oracle <name>] [--priority <PFA-P3>] [--client <name>]");
      process.exit(1);
    }

    // Body is the next argument if it is not a flag
    let body = parseFlag("--body");
    if (!body && args[titleIndex + 1] && !args[titleIndex + 1].startsWith("--")) {
      body = args[titleIndex + 1];
    }

    const opts: any = {
      body,
      oracle: parseFlag("--oracle"),
      repo: parseFlag("--repo"),
      type: parseFlag("--type"),
      priority: parseFlag("--priority"),
      client: parseFlag("--client"),
      wt: parseFlag("--wt"),
      worktree: args.includes("--worktree"),
    };

    const ctx = getContext();
    // Org mode dynamic defaults
    if (isOrg) {
      const gateway = (ctx as any).gateway;
      if (gateway) {
        if (!opts.oracle) opts.oracle = gateway.oracle;
        if (!opts.priority) opts.priority = gateway.priority;
        if (!opts.client) opts.client = gateway.client;
        if (!opts.repo) opts.repo = gateway.repo;
      } else {
        console.error("Error: Gateway configuration missing. Run 'pulse init' or add 'gateway' to config.");
        process.exit(1);
      }
    }

    await add(title, opts);
    break;
  }"""

# Replace the add case block
add_impl_esc = add_impl.replace('\\', '\\\\')
content = re.sub(r'  case "add":\n  case "a": \{[\s\S]+?break;\n  \}', add_impl_esc, content)

# 5.3 Ensure keyword command link if not present (v7.5)
if 'case "keyword":' not in content:
    kw_case = """  case "keyword":
  case "kw":
    await keyword(args);
    break;
  case "init":"""
    content = content.replace('  case "init":', kw_case)

open(path, 'w').write(content)
PY_EOF

# --- 6. Patch packages/cli/src/commands/add.ts ---
log_step "🛠️ Patching CLI add.ts (Metadata & Cross-Org)..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/add.ts')
content = open(path).read()

# Ensure setFieldOnItem is imported
if 'setFieldOnItem' not in content:
    content = content.replace('import { gh,', 'import { gh, setFieldOnItem,')

# Cross-Org targetRepo logic
if 'if (targetRepo && !targetRepo.includes("/")' not in content:
    content = content.replace('if (!targetRepo) targetRepo = `${ctx.org}/pulse-oracle`;',
                             'if (targetRepo && !targetRepo.includes("/")) targetRepo = `${ctx.org}/${targetRepo}`;\n  if (!targetRepo) targetRepo = `${ctx.org}/pulse-oracle`;')

# Metadata logic
client_logic = """
  if (opts.client) {
    try { await setFieldOnItem(ctx, addedItemId, "Client", opts.client); console.log(`Client: ${opts.client}`); } catch (e) {}
  }
  if (opts.priority) {
    try { await setFieldOnItem(ctx, addedItemId, "Priority", opts.priority); console.log(`Priority: ${opts.priority}`); } catch (e) {}
  }
  if (opts.oracle) {
    try { await setFieldOnItem(ctx, addedItemId, "Oracle", opts.oracle); console.log(`Oracle: ${opts.oracle}`); } catch (e) {}
  }
"""
if 'if (opts.client)' not in content:
    content = content.replace('return addedItemId;', client_logic + '\n  return addedItemId;')

open(path, 'w').write(content)
PY_EOF

log_step "✅ Comprehensive Patch Complete (v7.7)!"
