#!/bin/bash
# Surgical Patch Orchestrator for Multi-Project CHB (v8.5.2)
# Standard: Architecture v3.0 | Robust Patching v2.5

if [ -z "$1" ]; then
  echo "Usage: $0 <pulse-cli-path>"
  exit 1
fi

export PULSE_PATH=$(realpath "$1")
export PAYLOADS_DIR="$(realpath "$(dirname "$0")/payloads")"

# 0. TARGET CLEAN (Mandatory for Robust Patching)
echo "🧹 Cleaning Target Repo: $PULSE_PATH..."
cd "$PULSE_PATH" || exit 1
git fetch origin > /dev/null 2>&1
git reset --hard origin/main > /dev/null 2>&1
git clean -fd > /dev/null 2>&1
echo "✅ Target is now Clean Baseline (v8.5.1)."

# 1. RUNTIME BACKUP
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.config/pulse/backups/patch_v8.5.2_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
echo "📂 Backup: $BACKUP_DIR"

FILES=(
  "packages/cli/src/config.ts"
  "packages/cli/src/commands/chb.ts"
  "packages/cli/src/commands/init.ts"
)

for f in "${FILES[@]}"; do
  if [ -f "$PULSE_PATH/$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$PULSE_PATH/$f" "$BACKUP_DIR/$f"
  fi
done

# 2. HELPER FUNCTIONS
function apply_payload() {
  local target_file="$1"
  local feature="$2"
  local anchor_start="$3"
  local payload_name="$4"
  local mode="${5:-insert}"
  local anchor_end="$6"

  echo "🛠️  Checking $feature in $(basename "$target_file")..."
  
  export T_FILE="$target_file"
  export T_TAG="$feature"
  export T_START="$anchor_start"
  export T_PAYLOAD="$payload_name"
  export T_MODE="$mode"
  export T_END="$anchor_end"

  python3 - <<'PY_EOF'
import os, sys, re

pulse_path = os.environ.get("PULSE_PATH")
payloads_dir = os.environ.get("PAYLOADS_DIR")
target_file = os.environ.get("T_FILE")
tag = os.environ.get("T_TAG")
start = os.environ.get("T_START").replace("\\n", "\n")
payload_name = os.environ.get("T_PAYLOAD")
mode = os.environ.get("T_MODE")
end = os.environ.get("T_END").replace("\\n", "\n") if os.environ.get("T_END") else None

path = os.path.join(pulse_path, target_file)
payload_path = os.path.join(payloads_dir, payload_name)

if not os.path.exists(path):
    print(f"  ⚠️ Skipping: {path} not found")
    sys.exit(0)

with open(path, "r") as f:
    content = f.read()

# Robust Manifest Check
manifest_match = re.search(r"// @pulse-patch:.*", content)
if manifest_match and tag in manifest_match.group(0).split():
    print(f"  ✅ {tag} already present.")
    sys.exit(0)

if not os.path.exists(payload_path):
    print(f"  ❌ Error: Payload file not found: {payload_path}")
    sys.exit(1)

with open(payload_path, "r") as f:
    payload = f.read().strip()

# Injection
if mode == "replace_block":
    idx_start = content.find(start)
    if idx_start != -1:
        idx_end = content.find(end, idx_start + len(start))
        if idx_end != -1:
             content = content[:idx_start] + payload + content[idx_end + len(end):]
        else:
             print(f"  ❌ Error: Block end anchor not found in {target_file}")
             sys.exit(1)
    else:
        print(f"  ❌ Error: Block start anchor not found in {target_file}")
        sys.exit(1)
elif mode == "replace_line":
    if start in content:
        content = content.replace(start, payload)
    else:
        print(f"  ❌ Error: Line anchor not found in {target_file}")
        sys.exit(1)
else: # Default: insert before start
    if start in content:
        content = content.replace(start, payload + "\n" + start)
    else:
        print(f"  ❌ Error: Anchor not found in {target_file}")
        sys.exit(1)

# Manifest Management
if "// @pulse-patch:" in content:
    lines = content.split("\n")
    for i, line in enumerate(lines):
        if line.startswith("// @pulse-patch:"):
            if tag not in line: lines[i] = line.rstrip() + f" {tag}"
            break
    content = "\n".join(lines)
else:
    lines = content.split("\n")
    if len(lines) > 0 and lines[0].startswith("#!"):
        content = lines[0] + "\n" + f"// @pulse-patch: {tag}" + "\n" + "\n".join(lines[1:])
    else:
        content = f"// @pulse-patch: {tag}\n" + content

with open(path, "w") as f:
    f.write(content)
print(f"  ✨ Applied {tag}")
PY_EOF

  if [ $? -ne 0 ]; then
    echo "❌ Patch FAILED on $feature."
    exit 1
  fi
}

# 3. v8.5.2 PATCH SEQUENCES (Multi-Project CHB Support)

apply_payload "packages/cli/src/config.ts" "config_multi_project@v8.5.2" "export interface PulseConfig {" "config_multi_project@v8.5.2.pl" "replace_block" "  blog?: {"
apply_payload "packages/cli/src/config.ts" "config_resolver_logic@v8.5.2" "export function getCurrentOracle(): string | undefined {" "config_resolver_logic@v8.5.2.pl"

CHB_START="  const itbFull = cfg.board?.ITB || \"itinfosv/pulse-oracle\";"
CHB_END="  const isAIB = ctx.org.toLowerCase() === aibOrgContext.toLowerCase();"
apply_payload "packages/cli/src/commands/chb.ts" "chb_multi_project@v8.5.2" "$CHB_START" "chb_multi_project@v8.5.2.pl" "replace_block" "$CHB_END"

apply_payload "packages/cli/src/commands/init.ts" "init_questions@v8.5.2" "    // --- Phase 3: Identity & Path Resolution ---" "init_questions@v8.5.2.pl"

INIT_ASS_START="      config.board = {"
INIT_ASS_END="      };"
apply_payload "packages/cli/src/commands/init.ts" "init_board_assign@v8.5.2" "$INIT_ASS_START" "init_board_assign@v8.5.2.pl" "replace_block" "$INIT_ASS_END"

INIT_LIT_START="        board: {"
INIT_LIT_END="        },"
apply_payload "packages/cli/src/commands/init.ts" "init_board_literal@v8.5.2" "$INIT_LIT_START" "init_board_literal@v8.5.2.pl" "replace_block" "$INIT_LIT_END"

# 4. SYNTAX GUARD
echo "🛡️ Running Syntax Guard..."
cd "$PULSE_PATH"
if command -v bun &> /dev/null; then
  bun install --silent
  if bun build ./packages/cli/src/pulse.ts --outdir ./dist --target bun > /tmp/bun_build.log 2>&1; then
    echo "✅ Syntax Guard PASSED."
  else
    echo "❌ Syntax Guard FAILED. Check /tmp/bun_build.log"
    exit 1
  fi
fi

echo "🌊 Patch cycle complete for v8.5.2 (Multi-Project CHB)."
