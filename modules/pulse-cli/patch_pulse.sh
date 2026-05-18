#!/bin/bash
# Pulse Patch v8.3 - THE DEFINITIVE MASTER PATCH (Architecture v3.0)
# Cumulative: v7.5 - v8.3 (Decoupled Payloads, Status Sync, Task Pulling, Restoration)

if [ -z "$1" ]; then
  echo "Usage: $0 <pulse-cli-path> [--restore]"
  exit 1
fi

export PULSE_PATH=$(realpath "$1")
export PAYLOAD_DIR="$(dirname "$0")/payloads"
echo "🌊 Applying MASTER Patch v8.3 (Architecture v3.0) to $PULSE_PATH..."

# 0.2 RESTORE LOGIC
if [[ "$2" == "--restore" ]]; then
  BACKUP_ROOT="$HOME/.config/pulse/backups"
  LATEST_BACKUP=$(ls -td "$BACKUP_ROOT"/patch_* 2>/dev/null | head -1)
  if [ -n "$LATEST_BACKUP" ]; then
    echo "⏪ Restoring from latest backup: $LATEST_BACKUP..."
    cp -rv "$LATEST_BACKUP"/* "$PULSE_PATH/"
    echo "✅ Restoration complete."
    exit 0
  fi
fi

# 0. RESET & BACKUP
cd "$PULSE_PATH"
git checkout HEAD -- packages/sdk/src/types.ts packages/sdk/src/github.ts packages/cli/src/config.ts packages/cli/src/commands/init.ts packages/cli/src/commands/index.ts packages/cli/src/commands/add.ts packages/cli/src/commands/scan.ts packages/cli/src/pulse.ts 2>/dev/null

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.config/pulse/backups/patch_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
cp packages/sdk/src/types.ts packages/sdk/src/github.ts packages/cli/src/config.ts packages/cli/src/commands/init.ts packages/cli/src/commands/index.ts packages/cli/src/commands/add.ts packages/cli/src/commands/scan.ts packages/cli/src/pulse.ts "$BACKUP_DIR/" 2>/dev/null
echo "📂 Backup created at $BACKUP_DIR"

# ---------------------------------------------------------
# 1. SDK & CONFIG
# ---------------------------------------------------------
python3 - <<'EOF'
import os, re
path_t = os.path.join(os.environ['PULSE_PATH'], 'packages/sdk/src/types.ts')
content_t = open(path_t).read()
if 'gateway?:' not in content_t:
    content_t = content_t.replace('projectNumber: number;', 'projectNumber: number;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };\n  orchestrator?: string;')
open(path_t, 'w').write(content_t)

path_g = os.path.join(os.environ['PULSE_PATH'], 'packages/sdk/src/github.ts')
content_g = open(path_g).read()
if 'export async function setFieldOnItem' not in content_g:
    content_g = content_g.replace('async function setFieldOnItem', 'export async function setFieldOnItem')
open(path_g, 'w').write(content_g)

path_c = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/config.ts')
content_c = open(path_c).read()
if 'orchestrator?: string;' not in content_c:
    content_c = content_c.replace('oracleRepos: Record<string, string>;', 'oracleRepos: Record<string, string>;\n  orchestrator?: string;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };')
content_c = re.sub(r'return \{ org: cfg\.org, projectNumber: cfg\.projectNumber.*? \};', 
                 'return { org: cfg.org, projectNumber: cfg.projectNumber, gateway: cfg.gateway, orchestrator: cfg.orchestrator };', content_c)
if 'export function getCurrentOracle' not in content_c:
    func = r"""
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
    content_c = content_c.replace('export function getAllContexts()', func + '\nexport function getAllContexts()')
open(path_c, 'w').write(content_c)
EOF

# ---------------------------------------------------------
# 2. DECOUPLED PAYLOADS
# ---------------------------------------------------------

# A. Command Index
python3 - <<'EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/index.ts')
payload_dir = os.environ['PAYLOAD_DIR']
content = open(path).read()
if 'export { go }' not in content:
    content += open(os.path.join(payload_dir, 'index_export.v8.3.pch')).read()
if 'export { task }' not in content:
    content += 'export { task } from "./task";\n'
if 'export { keyword }' not in content:
    content += 'export { keyword } from "./keyword";\n'
open(path, 'w').write(content)
EOF

# B. add.ts Logic
python3 - <<'EOF'
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/add.ts')
payload_dir = os.environ['PAYLOAD_DIR']
content = open(path).read()

# Imports
if 'setFieldOnItem' not in content: content = content.replace('import { gh,', 'import { gh, setFieldOnItem,')
if 'getCurrentOracle' not in content: content = content.replace('import { getContext, getOracleRepos } from "../config";', 'import { getContext, getOracleRepos, getCurrentOracle } from "../config";')

# Authority Logic
auth_payload = open(os.path.join(payload_dir, 'add_authority.v8.3.pch')).read()
if 'const currentOracle' not in content:
    content = content.replace('const oracleLower = opts.oracle?.toLowerCase();', auth_payload)

# Routing Logic (v8.3 Centralization)
routing_payload = open(os.path.join(payload_dir, 'add_routing.v8.3.pch')).read()
# Identify the original block and replace it
pattern = r'let targetRepo = opts\.repo;.*?if \(!targetRepo\) targetRepo = `\$\{ctx\.org\}/pulse-oracle`;'
content = re.sub(pattern, routing_payload, content, flags=re.DOTALL)

# Metadata Logic
meta_payload = open(os.path.join(payload_dir, 'add_metadata.v8.3.pch')).read()
if 'if (opts.client)' not in content:
    content = content.replace('return addedItemId;', meta_payload + '\n  return addedItemId;')

open(path, 'w').write(content)
EOF

# C. Command Implementations
cp "$PAYLOAD_DIR/go.v8.3.pch" "$PULSE_PATH/packages/cli/src/commands/go.ts"

# D. pulse.ts (Entry Case)
python3 - <<'EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/pulse.ts')
payload_dir = os.environ['PAYLOAD_DIR']
content = open(path).read()
payload = open(os.path.join(payload_dir, 'pulse_case.v8.3.pch')).read()

if 'case "go":' in content:
    content = content.replace('  case "go":', '  case "start_alias":')

if 'case "activate":' not in content:
    content = content.replace('case "set":', payload + '  case "set":')

if 'function enforceAuth()' not in content:
    auth_fn = r'''function enforceAuth() {
  const current = (require("./config")).getCurrentOracle();
  const orchestrator = (require("./config")).getContext().orchestrator;
  if (orchestrator && current !== orchestrator) {
    console.error("Only the designated Orchestrator can perform board management.");
    process.exit(1);
  }
}'''
    content = content.replace('const [cmd, ...args]', auth_fn + '\n\nconst [cmd, ...args]')

open(path, 'w').write(content)
EOF

# ---------------------------------------------------------
# 3. SYNTAX GUARD
# ---------------------------------------------------------
echo "🛡️ Running Syntax Guard..."
cd "$PULSE_PATH"
bun build packages/cli/src/pulse.ts --target bun --outdir /tmp/pulse-check > /tmp/pulse-error.log 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Syntax Guard FAILED! Error in patched files."
  cat /tmp/pulse-error.log | head -n 20
  echo "⏪ Rolling back..."
  cp -rv "$BACKUP_DIR"/* "$PULSE_PATH/"
  exit 1
fi
echo "✅ Syntax Guard PASSED."

echo "✅ MASTER Patch v8.3 Applied successfully."
