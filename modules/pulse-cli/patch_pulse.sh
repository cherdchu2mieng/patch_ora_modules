#!/bin/bash
# Pulse Patch v8.1 - THE DEFINITIVE MASTER PATCH
# Cumulative: v7.5 - v8.1 (Centralized Board Authority, Restoration, Secure Auth, Hash Prefix)

if [ -z "$1" ]; then
  echo "Usage: $0 <pulse-cli-path> [--restore]"
  exit 1
fi

export PULSE_PATH=$(realpath "$1")
echo "🌊 Applying MASTER Patch v8.1: Centralized Board Authority to $PULSE_PATH..."

# 0.2 RESTORE LOGIC (Standard v1.5)
if [[ "$2" == "--restore" ]]; then
  BACKUP_ROOT="$HOME/.config/pulse/backups"
  if [ ! -d "$BACKUP_ROOT" ]; then
    echo "❌ Error: No backup directory found at $BACKUP_ROOT"
    exit 1
  fi
  
  LATEST_BACKUP=$(ls -td "$BACKUP_ROOT"/patch_* 2>/dev/null | head -1)
  if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Error: No backups found in $BACKUP_ROOT"
    exit 1
  fi
  
  echo "⏪ Restoring from latest backup: $LATEST_BACKUP..."
  cp -rv "$LATEST_BACKUP"/* "$PULSE_PATH/"
  echo "✅ Restoration complete. Source files returned to pre-patch state."
  exit 0
fi

# 0. RESET TO BASELINE
cd "$PULSE_PATH"
echo "📦 Resetting source to clean baseline..."
git checkout HEAD -- packages/sdk/src/types.ts packages/sdk/src/github.ts packages/cli/src/config.ts packages/cli/src/commands/init.ts packages/cli/src/commands/index.ts packages/cli/src/commands/add.ts packages/cli/src/commands/scan.ts packages/cli/src/pulse.ts

# 0.5 RUNTIME BACKUP
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_ROOT="$HOME/.config/pulse/backups"
BACKUP_DIR="$BACKUP_ROOT/patch_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
echo "📂 Backing up files to $BACKUP_DIR..."

FILES=(
  "packages/sdk/src/types.ts"
  "packages/sdk/src/github.ts"
  "packages/cli/src/config.ts"
  "packages/cli/src/commands/init.ts"
  "packages/cli/src/commands/index.ts"
  "packages/cli/src/commands/add.ts"
  "packages/cli/src/commands/scan.ts"
  "packages/cli/src/pulse.ts"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$file")"
    cp "$file" "$BACKUP_DIR/$file"
  fi
done
echo "✓ Backup completed."

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
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/config.ts')
content = open(path).read()

if 'orchestrator?: string;' not in content:
    content = content.replace('oracleRepos: Record<string, string>;', 'oracleRepos: Record<string, string>;\n  orchestrator?: string;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };')

content = re.sub(r'return \{ org: cfg\.org, projectNumber: cfg\.projectNumber.*? \};', 
                 'return { org: cfg.org, projectNumber: cfg.projectNumber, gateway: cfg.gateway, orchestrator: cfg.orchestrator };', content)

if 'export function getCurrentOracle' not in content:
    func = """
/** Determine current oracle name based on env or current directory */
export function getCurrentOracle(): string | undefined {
  if (process.env.ORACLE_NAME) return process.env.ORACLE_NAME.toLowerCase();

  const currentFolder = require('path').basename(process.cwd()).toLowerCase();
  const repos = loadConfig().oracleRepos;
  for (const [oracle, repo] of Object.entries(repos)) {
    if (repo.toLowerCase() === currentFolder) return oracle.toLowerCase();
  }
  return undefined;
}
"""
    content = content.replace('export function getAllContexts()', func + '\nexport function getAllContexts()')

open(path, 'w').write(content)
CONFIG_EOF
echo "✓ Patched CLI Config"

# 3. CLI init.ts
python3 - <<'INIT_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/init.ts')
content = open(path).read()
if "import * as fs from 'fs'" not in content:
    content = "import * as fs from 'fs';\nimport * as path from 'path';\nimport { homedir } from 'os';\n" + content
open(path, 'w').write(content)
INIT_EOF
echo "✓ Patched Init Logic"

# 4. CLI add.ts
python3 - <<'ADD_EOF'
import os, re
path_a = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/add.ts')
content_a = open(path_a).read()

if 'setFieldOnItem' not in content_a:
    content_a = content_a.replace('import { gh,', 'import { gh, setFieldOnItem,')

if 'getCurrentOracle' not in content_a:
    content_a = content_a.replace('import { getContext, getOracleRepos } from "../config";', 'import { getContext, getOracleRepos, getCurrentOracle } from "../config";')

# Requirement 1.2 & 1.3: Authority & Express Lane
req_logic = r'''
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
'''
if 'const currentOracle' not in content_a:
    content_a = content_a.replace('const oracleLower = opts.oracle?.toLowerCase();', req_logic)

# v8.1: Centralized Master Board Authority
routing_block = r'''  if (!targetRepo && oracleLower) {
    const repoName = getOracleRepos()[oracleLower];
    if (repoName) targetRepo = `${ctx.org}/${repoName}`;
  }'''
content_a = content_a.replace(routing_block, '  // v8.1: Centralized Master Board Authority')

if 'if (!targetRepo) targetRepo = `${ctx.org}/pulse-oracle`;' not in content_a:
    content_a = content_a.replace('let targetRepo = opts.repo;', 'let targetRepo = opts.repo;\n  if (!targetRepo) targetRepo = `${ctx.org}/pulse-oracle`;')

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
echo "✓ Patched Add Logic"

# 5. CLI pulse.ts
python3 - <<'PULSE_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/pulse.ts')
content = open(path).read()
if 'import { getContext }' not in content:
    content = content.replace('import { board', 'import { getContext } from "./config";\nimport { board')
content = content.replace('Pulse Oracle', 'Pulse Oracle v8.1 (patched 🌊)')

auth_fn = r'''function enforceAuth() {
  if (getContext().orchestrator && process.env.ORACLE_NAME !== getContext().orchestrator) {
    console.error("Only the designated Orchestrator can perform board management.");
    process.exit(1);
  }
}'''
if 'function enforceAuth()' not in content:
    content = content.replace('const [cmd, ...args]', auth_fn + '\n\nconst [cmd, ...args]')
content = content.replace('case "set":\n  case "s":', 'case "set":\n  case "s":\n    enforceAuth();')
content = content.replace('case "triage":\n  case "tr":', 'case "triage":\n  case "tr":\n    enforceAuth();')

open(path, 'w').write(content)
PULSE_EOF
echo "✓ Patched CLI Entry"

echo "✅ MASTER Patch v8.1 Applied successfully."
