#!/bin/bash
# Pulse Patch v8.3 - THE DEFINITIVE MASTER PATCH (Ironclad v2.0)
# Cumulative Features: 
#   [v8.1] Centralized Board Authority
#   [v8.2] Secure Orchestrator Guard & Task Pulling
#   [v8.3] Bidirectional Status Sync (pulse go)

if [ -z "$1" ]; then
  echo "Usage: $0 <pulse-cli-path> [--restore]"
  exit 1
fi

export PULSE_PATH=$(realpath "$1")
export PAYLOAD_DIR="$(dirname "$0")/payloads"
echo "🌊 Applying MASTER Patch v8.3 (Ironclad v2.0) to $PULSE_PATH..."

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

cd "$PULSE_PATH"
git checkout HEAD -- packages/sdk/src/types.ts packages/sdk/src/github.ts packages/cli/src/config.ts packages/cli/src/commands/init.ts packages/cli/src/commands/index.ts packages/cli/src/commands/add.ts packages/cli/src/commands/scan.ts packages/cli/src/pulse.ts 2>/dev/null

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.config/pulse/backups/patch_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
cp packages/sdk/src/types.ts packages/sdk/src/github.ts packages/cli/src/config.ts packages/cli/src/commands/init.ts packages/cli/src/commands/index.ts packages/cli/src/commands/add.ts packages/cli/src/commands/scan.ts packages/cli/src/pulse.ts "$BACKUP_DIR/" 2>/dev/null
echo "📂 Backup created at $BACKUP_DIR"

python3 - <<"EOF_PY"
import os, re
path_t = os.path.join(os.environ["PULSE_PATH"], "packages/sdk/src/types.ts")
content_t = open(path_t).read()
if "gateway?:" not in content_t:
    content_t = content_t.replace("projectNumber: number;", "projectNumber: number;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };\n  orchestrator?: string;")
open(path_t, "w").write(content_t)

path_g = os.path.join(os.environ["PULSE_PATH"], "packages/sdk/src/github.ts")
content_g = open(path_g).read()
if "export async function setFieldOnItem" not in content_g:
    content_g = content_g.replace("async function setFieldOnItem", "export async function setFieldOnItem")
open(path_g, "w").write(content_g)

path_c = os.path.join(os.environ["PULSE_PATH"], "packages/cli/src/config.ts")
content_c = open(path_c).read()
if "orchestrator?: string;" not in content_c:
    content_c = content_c.replace("oracleRepos: Record<string, string>;", "oracleRepos: Record<string, string>;\n  orchestrator?: string;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };")
content_c = re.sub(r"return \{ org: cfg\.org, projectNumber: cfg\.projectNumber.*? \};", "return { org: cfg.org, projectNumber: cfg.projectNumber, gateway: cfg.gateway, orchestrator: cfg.orchestrator };", content_c)
if "export function getCurrentOracle" not in content_c:
    func = r"""
export function getCurrentOracle(): string | undefined {
  if (process.env.ORACLE_NAME) return process.env.ORACLE_NAME.toLowerCase();
  const currentFolder = require("path").basename(process.cwd()).toLowerCase();
  const repos = loadConfig().oracleRepos;
  for (const [oracle, repo] of Object.entries(repos)) {
    if (repo.toLowerCase() === currentFolder) return oracle.toLowerCase();
  }
  return undefined;
}
"""
    content_c = content_c.replace("export function getAllContexts()", func + "\nexport function getAllContexts()")
open(path_c, "w").write(content_c)
EOF_PY

python3 - <<"EOF_PY"
import os
path = os.path.join(os.environ["PULSE_PATH"], "packages/cli/src/commands/index.ts")
content = open(path).read()
for cmd in ["go", "task", "keyword"]:
    line = f"export {{ {cmd} }} from \"./{cmd}\";\n"
    if line not in content: content += line
open(path, "w").write(content)
EOF_PY

python3 - <<"EOF_PY"
import os
path = os.path.join(os.environ["PULSE_PATH"], "packages/cli/src/pulse.ts")
content = open(path).read()
content = content.replace("Pulse Oracle", "Pulse Oracle v8.3 (Ironclad :wave:)")
if "getCurrentOracle" not in content:
    content = content.replace("import { board", "import { getContext, getCurrentOracle } from \"./config\";\nimport { board")
if "function enforceAuth()" not in content:
    auth_fn = r"""function enforceAuth() {
  const current = getCurrentOracle();
  const orchestrator = getContext().orchestrator;
  if (orchestrator && current !== orchestrator) {
    console.error("Only the designated Orchestrator can perform board management.");
    process.exit(1);
  }
}"""
    content = content.replace("const [cmd, ...args]", auth_fn + "\n\nconst [cmd, ...args]")
if "case \"task\":" not in content:
    content = content.replace("case \"set\":", "  case \"task\":\n  case \"tk\": {\n    const { task } = require(\"./commands/index\");\n    if (!args[0]) { console.error(\"Usage: pulse task <ID>\"); process.exit(1); }\n    await task(parseInt(args[0]));\n    break;\n  }\n  case \"set\":")
if "case \"go\":" in content: content = content.replace("  case \"go\":", "  case \"start_alias\":")
if "case \"activate\":" not in content:
    content = content.replace("case \"set\":", "  case \"go\":\n  case \"activate\": {\n    const { go } = require(\"./commands/index\");\n    if (!args[0] || args[0].startsWith(\"--\")) { console.error(\"Usage: pulse go <ID>\"); process.exit(1); }\n    await go(parseInt(args[0]));\n    break;\n  }\n  case \"set\":")
content = content.replace("case \"set\":\n  case \"s\":", "case \"set\":\n  case \"s\":\n    enforceAuth();")
content = content.replace("case \"triage\":\n  case \"tr\":", "case \"triage\":\n  case \"tr\":\n    enforceAuth();")
open(path, "w").write(content)
EOF_PY

python3 - <<"EOF_PY"
import os, re
path = os.path.join(os.environ["PULSE_PATH"], "packages/cli/src/commands/add.ts")
payload_dir = os.environ["PAYLOAD_DIR"]
content = open(path).read()
auth_pch = open(os.path.join(payload_dir, "add_authority.pch")).read()
rout_pch = open(os.path.join(payload_dir, "add_routing.pch")).read()
meta_pch = open(os.path.join(payload_dir, "add_metadata.pch")).read()
if "getCurrentOracle" not in content:
    content = content.replace("import { getContext, getOracleRepos } from \"../config\"", "import { getContext, getOracleRepos, getCurrentOracle } from \"../config\"")
if "setFieldOnItem" not in content: content = content.replace("import { gh,", "import { gh, setFieldOnItem,")
if "const currentOracle" not in content: content = content.replace("const oracleLower = opts.oracle?.toLowerCase();", auth_pch)
pattern = r"let targetRepo = opts\\.repo;.*?if \\(!targetRepo\\) targetRepo = `\\\$\{ctx\\.org\\}/pulse-oracle`;"
content = re.sub(pattern, rout_pch, content, flags=re.DOTALL)
if "if (opts.client)" not in content: content = content.replace("return addedItemId;", meta_pch + "\n  return addedItemId;")
open(path, "w").write(content)
EOF_PY

cp "$PAYLOAD_DIR/go_status_sync.pch" "$PULSE_PATH/packages/cli/src/commands/go.ts"
cp "$PAYLOAD_DIR/task_pulling.pch" "$PULSE_PATH/packages/cli/src/commands/task.ts"

echo "🛡️ Running Syntax Guard..."
cd "$PULSE_PATH"
bun build packages/cli/src/pulse.ts --target bun --outdir /tmp/pulse-check > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Syntax Guard FAILED! Regression detected."
  exit 1
fi
echo "✅ Syntax Guard PASSED."
echo "✅ MASTER Patch v8.3 Applied successfully."
