#!/bin/bash
# pulse-cli Init Stabilization Orchestrator v8.5.3
# Goal: Simplified Init Flow & Board Context Fixes

if [ -z "$1" ]; then
  echo "Usage: $0 <target-repo-path>"
  exit 1
fi

export TARGET_PATH=$(realpath "$1")
export SCRIPT_DIR="$(realpath "$(dirname "$0")")"
export PAYLOADS_DIR="$SCRIPT_DIR/payloads"

# HELPER FUNCTIONS
function apply_payload() {
  local target_file="$1"
  local feature="$2"
  local anchor_start="$3"
  local payload_name="$4"
  local mode="${5:-insert}"
  local anchor_end="$6"

  echo "🛠️  Checking $feature in $target_file..."
  
  export T_FILE="$target_file"
  export T_TAG="$feature"
  export T_START="$anchor_start"
  export T_PAYLOAD="$payload_name"
  export T_MODE="$mode"
  export T_END="$anchor_end"

  python3 - <<'PY_EOF'
import os, sys, re

target_repo_path = os.environ.get("TARGET_PATH")
payloads_dir = os.environ.get("PAYLOADS_DIR")
target_file = os.environ.get("T_FILE")
tag = os.environ.get("T_TAG")
start = os.environ.get("T_START")
payload_name = os.environ.get("T_PAYLOAD")
mode = os.environ.get("T_MODE")
end = os.environ.get("T_END")

path = os.path.join(target_repo_path, target_file)
payload_path = os.path.join(payloads_dir, payload_name)

if not os.path.exists(path):
    print(f"  ⚠️ Skipping: {path} not found")
    sys.exit(0)

with open(path, "r") as f:
    content = f.read()

# Tag check
if f"// @pulse-patch: {tag}" in content:
    print(f"  ✅ {tag} already present.")
    sys.exit(0)

if not os.path.exists(payload_path):
    print(f"  ❌ Error: Payload file not found: {payload_path}")
    sys.exit(1)

with open(payload_path, "r") as f:
    payload = f.read().strip()

new_content = content
if mode == "replace_block":
    if start in content:
        idx_start = content.find(start)
        if end:
             if end == "END":
                 if target_file.endswith("init.ts") or target_file.endswith("chb.ts"):
                     idx_end = content.rfind("}")
                     if idx_end != -1 and idx_end > idx_start:
                          new_content = content[:idx_start] + payload + content[idx_end + 1:]
                     else:
                          print(f"  ❌ Error: Could not find closing brace for {tag}")
                          sys.exit(1)
             else:
                 idx_end = content.find(end, idx_start + len(start))
                 if idx_start != -1 and idx_end != -1:
                      new_content = content[:idx_start] + payload + content[idx_end + len(end):]
                 else:
                      print(f"  ❌ Error: Block anchors not found for {tag}")
                      sys.exit(1)
        else:
            new_content = content.replace(start, payload)
    else:
        print(f"  ❌ Error: Block start anchor not found: {start}")
        sys.exit(1)
elif mode == "replace_line":
    if start in content:
        new_content = content.replace(start, payload)
    else:
        print(f"  ❌ Error: Line anchor not found")
        sys.exit(1)
elif mode == "append":
    new_content = content.rstrip() + "\n" + payload + "\n"
else:
    if start in content:
        new_content = content.replace(start, payload + "\n" + start)
    else:
        print(f"  ❌ Error: Anchor not found")
        sys.exit(1)

# Add patch tag
lines = new_content.split("\n")
if len(lines) > 0 and lines[0].startswith("// @pulse-patch:"):
    if tag not in lines[0]:
        lines[0] = lines[0] + " " + tag
else:
    lines.insert(0, f"// @pulse-patch: {tag}")
new_content = "\n".join(lines)

with open(path, "w") as f:
    f.write(new_content)
print(f"  ✨ Applied {tag}")
PY_EOF

  if [ $? -ne 0 ]; then
    echo "❌ Execution failed for $feature"
    exit 1
  fi
}

echo "🚀 Starting Patch Execution (v8.5.3)..."

# 0. CLEAN RESET TARGET
cd "$TARGET_PATH" && git restore .

# CR-002: config.ts helpers
apply_payload "packages/cli/src/config.ts" "config_type_safety@v8.5.3" "" "config_type_safety@v8.5.3.pl" "append"

# CR-002: blog.ts fix
apply_payload "packages/cli/src/commands/blog.ts" "blog_imports_fix@v8.5.3" "import { getContext, getRepoName, loadConfig } from \"../config\";" "blog_imports@v8.5.3.pl" "replace_line"
apply_payload "packages/cli/src/commands/blog.ts" "blog_type_fix@v8.5.3" '  const cfg = loadConfig();
  const org = ctx.org;
const blogRepo = cfg.blog?.repo || (typeof cfg.board === "object" ? cfg.board.ITB : "itinfosv/pulse-oracle");
  const [targetOrg, targetRepo] = blogRepo.includes("/") ? blogRepo.split("/") : [org, blogRepo];' "blog_type_fix@v8.5.3.pl" "replace_block" ""

# CR-001: init.ts rewrite
apply_payload "packages/cli/src/commands/init.ts" "init_ux_refine@v8.5.3" "export async function init() {" "init_ux_refine@v8.5.3.pl" "replace_block" "END"

# CR-003: chb.ts context fix
apply_payload "packages/cli/src/commands/chb.ts" "chb_imports_fix@v8.5.3" "import { getContext, getCurrentOracle, loadConfig } from \"../config\";" "chb_imports@v8.5.3.pl" "replace_line"
apply_payload "packages/cli/src/commands/chb.ts" "chb_context_fix@v8.5.3" "export async function chb(" "chb_context_fix@v8.5.3.pl" "replace_block" "END"

echo "🏁 Patching Complete (v8.5.3)."
