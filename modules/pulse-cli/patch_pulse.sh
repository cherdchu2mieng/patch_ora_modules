#!/bin/bash
# Pulse Patch v8.3 - THE DEFINITIVE MASTER PATCH (Ironclad v2.1)
# Incremental & Feature-Tagged Architecture

if [ -z "$1" ]; then echo "Usage: $0 <pulse-cli-path> [--restore]"; exit 1; fi

export PULSE_PATH=$(realpath "$1")
export PAYLOAD_DIR="$(cd "$(dirname "$0")/payloads" && pwd)"
echo "🌊 Applying MASTER Patch v8.3 (Ironclad v2.1) to $PULSE_PATH..."

if [[ "$2" == "--restore" ]]; then
  BACKUP_ROOT="$HOME/.config/pulse/backups"
  LATEST_BACKUP=$(ls -td "$BACKUP_ROOT"/patch_* 2>/dev/null | head -1)
  if [ -n "$LATEST_BACKUP" ]; then
    echo "⏪ Restoring from latest backup: $LATEST_BACKUP..."
    cp -rv "$LATEST_BACKUP"/* "$PULSE_PATH/"
    echo "✅ Restoration complete."; exit 0; fi
fi

cd "$PULSE_PATH"
git checkout HEAD -- packages/sdk/src/types.ts packages/sdk/src/github.ts packages/cli/src/config.ts packages/cli/src/commands/init.ts packages/cli/src/commands/index.ts packages/cli/src/commands/add.ts packages/cli/src/pulse.ts 2>/dev/null

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.config/pulse/backups/patch_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
cp packages/sdk/src/types.ts packages/sdk/src/github.ts packages/cli/src/config.ts packages/cli/src/commands/init.ts packages/cli/src/commands/index.ts packages/cli/src/commands/add.ts packages/cli/src/pulse.ts "$BACKUP_DIR/" 2>/dev/null
echo "📂 Backup created at $BACKUP_DIR"

# 1. DEPLOY COMMAND FILES (The Foundation)
python3 - <<"EOF_PY"
import os
p_path = os.environ["PULSE_PATH"]
p_dir = os.environ["PAYLOAD_DIR"]
for name, pch, tag in [("go.ts", "go_status_sync.v8.3.pch", "go_status_sync@v8.3"), ("task.ts", "task_pulling.v8.2.pch", "task_pulling@v8.2")]:
    with open(os.path.join(p_path, "packages/cli/src/commands", name), "w") as f:
        f.write("// @pulse-patch: " + tag + "\n" + open(os.path.join(p_dir, pch)).read())
EOF_PY

cat << "K_EOF" > "$PULSE_PATH/packages/cli/src/commands/keyword.ts"
import * as fs from "fs";
import * as path from "path";
export async function keyword(args: string[]) {
  const sub = args[0];
  if (sub !== "sync") { console.log("Usage: pulse keyword sync"); return; }
  const localConfigPath = path.join(process.cwd(), "pulse.config.json");
  const targetPath = fs.realpathSync(localConfigPath);
  const config = JSON.parse(fs.readFileSync(targetPath, "utf8"));
  const currentRepo = path.basename(process.cwd());
  const oracleName = config.routing?.repo?.[currentRepo];
  if (!oracleName) { console.error("Error: Repo not mapped."); return; }
  const claudePath = path.join(process.cwd(), "CLAUDE.md");
  const docContent = fs.readFileSync(claudePath, "utf8");
  let keywords: string[] = [];
  const kwMatch = docContent.match(/\*\*Keywords\*\*:\s*([\s\S]+?)(?=\n\n|\n#|$)/);
  if (kwMatch) {
    const kwLines = kwMatch[1].split("\n");
    for (const line of kwLines) {
      const match = line.match(/^\s*-\s+(?:[^:]+:)?\s*(.+)$/);
      if (match) { keywords.push(...match[1].split(",").map(w => w.trim())); }
    }
  }
  if (!config.routing) config.routing = {};
  if (!config.routing.keyword) config.routing.keyword = [];
  const existingIdx = config.routing.keyword.findIndex((k: any) => k.oracle === oracleName);
  if (existingIdx !== -1) { config.routing.keyword[existingIdx].match = keywords; }
  else { config.routing.keyword.push({ match: keywords, oracle: oracleName }); }
  fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + "\n");
  console.log("Successfully updated config.");
}
K_EOF

python3 - <<"EOF_PY"
import os, re
payload_dir = os.environ["PAYLOAD_DIR"]

def apply_patch(file_rel_path, tag, pch_file, anchor, is_replace=True):
    path = os.path.join(os.environ["PULSE_PATH"], file_rel_path)
    if not os.path.exists(path): return
    with open(path, "r") as f: content = f.read()
    lines = content.split("\n")
    applied = []
    if len(lines) > 0 and lines[0].startswith("// @pulse-patch:"):
        applied = lines[0].replace("// @pulse-patch:", "").strip().split(", ")
    if tag in applied: return
    print(f"🛠️ {file_rel_path}: Applying {tag}...")
    payload = open(os.path.join(payload_dir, pch_file)).read()
    if is_replace: new_content = re.sub(anchor, payload, content, flags=re.DOTALL)
    else: new_content = content.replace(anchor, anchor + "\n" + payload)
    if tag not in applied: applied.append(tag)
    new_header = "// @pulse-patch: " + ", ".join(sorted(applied))
    lines = new_content.split("\n")
    if len(lines) > 0 and lines[0].startswith("// @pulse-patch:"): lines[0] = new_header
    else: lines.insert(0, new_header)
    with open(path, "w") as f: f.write("\n".join(lines))
    print(f"✅ {file_rel_path}: {tag} Success")

apply_patch("packages/sdk/src/types.ts", "sdk_types@v7.5", "sdk_types_expansion.v7.5.pch", r"projectNumber: number;", False)
apply_patch("packages/cli/src/config.ts", "config_interface@v7.5", "config_interface_expansion.v7.5.pch", r"oracleRepos: Record<string, string>;", False)
apply_patch("packages/cli/src/commands/init.ts", "init_helper@v7.8", "init_gh_helper.v7.8.pch", r"export async function init\\(\\)", False)
apply_patch("packages/sdk/src/github.ts", "sdk_github_export@v7.11", "sdk_github_export.v7.11.pch", r"async function setFieldOnItem")
apply_patch("packages/cli/src/config.ts", "config_identity@v7.11", "config_identity_detection.v7.11.pch", r"export function getAllContexts\\(\\)", False)
apply_patch("packages/cli/src/config.ts", "config_context@v8.1", "config_context_return.v8.1.pch", r"return \\{ org: cfg\\.org, projectNumber: cfg\\.projectNumber.*? \\};")
apply_patch("packages/cli/src/commands/add.ts", "add_authority@v8.2", "add_authority.v8.2.pch", r"const oracleLower = opts\\.oracle\\?\\.toLowerCase\\(\\)\\\;")
apply_patch("packages/cli/src/commands/add.ts", "add_routing@v8.3", "add_routing.v8.3.pch", r"let targetRepo = opts\\.repo\\\;.*?if \\(\\!targetRepo\\) targetRepo = \\`\\$\\{ctx\\.org\\}/pulse-oracle\\`\\\;")
apply_patch("packages/cli/src/commands/add.ts", "add_metadata@v7", "add_metadata.v7.pch", r"return addedItemId;", is_replace=False)

path_p = os.path.join(os.environ["PULSE_PATH"], "packages/cli/src/pulse.ts")
with open(path_p, "r") as f: p_content = f.read()
if "Ironclad v2.1" not in p_content:
    p_content = p_content.replace("Pulse Oracle", "Pulse Oracle v8.3 (Ironclad v2.1 🌊)")
    p_content = p_content.replace("import { board", "import { getContext, getCurrentOracle } from \"./config\";\\nimport { board")
    auth_fn = "function enforceAuth() { const c = (require(\\\"./config\\\")).getCurrentOracle(); const o = (require(\\\"./config\\\")).getContext().orchestrator; if (o && c !== o) { console.error(\\\"Only the designated Orchestrator can perform board management.\\\\"); process.exit(1); } }"
    p_content = p_content.replace("const [cmd, ...args]", auth_fn + "\\n\\nconst [cmd, ...args]")
    p_content = p_content.replace("case \\\"set\\\":\", "  case \\\"task\\\":\\n  case \\\"tk\\\": { const { task } = require(\\\"./commands/index\\\"); await task(parseInt(args[0])); break; }\\n  case \\\"set\\\":\")
    p_content = p_content.replace("case \\\"go\\\":\", \"  case \\\"start_alias\\\":\")
    p_content = p_content.replace("case \\\"set\\\":\", \"  case \\\"go\":\\n  case \\\"activate\": { const { go } = require(\\\"./commands/index\\\"); await go(parseInt(args[0])); break; }\\n  case \\\"set\\\":\")
    with open(path_p, "w") as f: f.write(p_content)

path_i = os.path.join(os.environ["PULSE_PATH"], "packages/cli/src/commands/index.ts")
with open(path_i, "r") as f: i_content = f.read()
for cmd in ["go", "task", "keyword"]: 
    line = f"export {{ {cmd} }} from \"./{cmd}\";"
    if line not in i_content: i_content += line + "\n"
with open(path_i, "w") as f: f.write(i_content)
EOF_PY

echo "🛡️ Running Syntax Guard..."
cd "$PULSE_PATH"
bun build packages/cli/src/pulse.ts --target bun --outdir /tmp/pulse-check > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "❌ Syntax Guard FAILED! Regression detected."; exit 1; fi
echo "✅ Syntax Guard PASSED."
echo "✅ MASTER Patch v8.3 (Ironclad v2.1) Applied successfully."
