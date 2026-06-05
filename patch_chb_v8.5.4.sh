#!/bin/bash
# pulse-cli CHB Refinement v8.5.4
# Goal: Remove Oracle constraint during AIB handover

if [ -z "$1" ]; then
  echo "Usage: $0 <target-repo-path>"
  exit 1
fi

export TARGET_PATH=$(realpath "$1")
export SCRIPT_DIR="$(realpath "$(dirname "$0")")"
export PAYLOADS_DIR="$SCRIPT_DIR/payloads"

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
             idx_end = content.find(end, idx_start + len(start))
             if idx_start != -1 and idx_end != -1:
                  new_content = content[:idx_start] + payload + content[idx_end + len(end):]
             else:
                  print(f"  ❌ Error: Block anchors found but overlap or logic failure")
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
        print(f"  ❌ Error: Line anchor not found: {start}")
        sys.exit(1)
elif mode == "append":
    new_content = content.rstrip() + "\n" + payload + "\n"
else:
    if start in content:
        new_content = content.replace(start, payload + "\n" + start)
    else:
        print(f"  ❌ Error: Anchor not found: {start}")
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

echo "🚀 Starting Patch Execution (v8.5.4)..."

cd "$TARGET_PATH" && git restore packages/cli/src/commands/chb.ts

apply_payload "packages/cli/src/commands/chb.ts" "chb_remove_aib_oracle@v8.5.4" '       await setFieldOnItem(aibCtx, aibItemId, "Status", "New");' "chb_remove_aib_oracle@v8.5.4.pl" "replace_block" 'console.log("  Board (AIB): ✅ Oracle=" + orchestratorName + ", Priority=P1, Client=AI-Team");'

echo "🏁 Patching Complete (v8.5.4)."
