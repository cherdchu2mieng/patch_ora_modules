#!/bin/bash
# Pulse Patch Orchestrator v8.4.2 (Ironclad v2.3)
# Cumulative, Manifest-Driven, Idempotent

if [ -z "$1" ]; then
  echo "Usage: $0 <pulse-cli-path> [--restore]"
  exit 1
fi

export PULSE_PATH=$(realpath "$1")
export PAYLOADS_DIR="$(dirname "$0")/modules/pulse-cli/payloads"
echo "🌊 Applying MASTER Patch v8.4.2 (Ironclad v2.3) to $PULSE_PATH..."

# 0. RESTORE LOGIC
if [[ "$2" == "--restore" ]]; then
  BACKUP_ROOT="$HOME/.config/pulse/backups"
  LATEST_BACKUP=$(ls -td "$BACKUP_ROOT"/patch_* 2>/dev/null | head -1)
  if [ -z "$LATEST_BACKUP" ]; then echo "❌ No backups found."; exit 1; fi
  echo "⏪ Restoring from $LATEST_BACKUP..."
  cp -rv "$LATEST_BACKUP"/* "$PULSE_PATH/"
  echo "✅ Restoration complete."
  exit 0
fi

# 1. RUNTIME BACKUP
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.config/pulse/backups/patch_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
echo "📂 Backup: $BACKUP_DIR"

FILES=(
  "packages/cli/src/pulse.ts"
  "packages/cli/src/commands/add.ts"
  "packages/cli/src/commands/board.ts"
  "packages/cli/src/commands/triage.ts"
  "packages/cli/src/commands/set.ts"
  "packages/cli/src/commands/start.ts"
  "packages/cli/src/commands/init.ts"
  "packages/cli/src/commands/keyword.ts"
  "packages/cli/src/commands/index.ts"
  "packages/cli/src/config.ts"
  "packages/cli/src/commands/blog.ts"
  "packages/cli/src/commands/close.ts"
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
start = os.environ.get("T_START")
payload_name = os.environ.get("T_PAYLOAD")
mode = os.environ.get("T_MODE")
end = os.environ.get("T_END")

path = os.path.join(pulse_path, target_file)
payload_path = os.path.join(payloads_dir, payload_name)

original_content = ""
shebang = ""
if os.path.exists(path):
    with open(path, "r") as f:
        original_content = f.read()
    if original_content.startswith("#!"):
        shebang = original_content.split("\n")[0] + "\n"

# Idempotency Check
if tag in original_content and mode != "full_replace" and mode != "create":
    print(f"  ✅ {tag} already present.")
    sys.exit(0)

if not os.path.exists(payload_path):
    if mode == "create":
        print(f"  ⚠️ Creating mode but payload missing: {payload_path}")
        sys.exit(1)
    print(f"  ⚠️ Skipping: {path} not found")
    sys.exit(0)

with open(payload_path, "r") as f:
    payload = f.read().strip()

content = original_content

# Injection
if mode == "full_replace" or mode == "create":
    content = shebang + f"// @pulse-patch: {tag}\n" + payload
else:
    # Manifest Management for existing files (Insert Mode)
    manifest_match = re.search(r"^// @pulse-patch:.*", content, re.MULTILINE)
    if manifest_match:
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if line.startswith("// @pulse-patch:"):
                lines[i] = line.rstrip() + f" {tag}"
                break
        content = "\n".join(lines)
    else:
        if shebang:
            content = shebang + f"// @pulse-patch: {tag}\n" + content[len(shebang):]
        else:
            content = f"// @pulse-patch: {tag}\n" + content

    if mode == "replace_block":
        if start in content and end in content:
            parts = content.split(start, 1)
            post_parts = parts[1].split(end, 1)
            content = parts[0] + payload + "\n" + post_parts[1]
        else:
            print(f"  ❌ Error: Block start/end not found in {target_file}")
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

with open(path, "w") as f:
    f.write(content)
print(f"  ✨ Applied {tag}")
PY_EOF

  if [ $? -ne 0 ]; then
    echo "❌ Patch FAILED on $feature."
    exit 1
  fi
}

# 2.5 CORE INFRASTRUCTURE (Sacred + New)
apply_payload "packages/cli/src/config.ts" "cmd_config@v8.4.0" "" "cmd_config@v8.4.0.pl" "full_replace"

# 3. COMMANDS (Cumulative Sacred)
apply_payload "packages/cli/src/commands/init.ts" "cmd_init@v8.4.0" "" "cmd_init@v8.4.0.pl" "full_replace"
apply_payload "packages/cli/src/commands/keyword.ts" "cmd_keyword@v8.2.1" "" "cmd_keyword@v8.2.1.pl" "full_replace"

# 4. COMMANDS (v8.4.0 Features)
apply_payload "packages/cli/src/commands/add.ts" "cmd_add@v8.4.0" "" "cmd_add@v8.4.0.pl" "full_replace"
apply_payload "packages/cli/src/commands/board.ts" "cmd_board@v8.4.0" "" "cmd_board@v8.4.0.pl" "full_replace"
apply_payload "packages/cli/src/commands/triage.ts" "cmd_triage@v8.4.0" "" "cmd_triage@v8.4.0.pl" "full_replace"
apply_payload "packages/cli/src/commands/set.ts" "set_cmd@v8.4.0" "" "set_cmd@v8.4.0.pl" "full_replace"
apply_payload "packages/cli/src/commands/start.ts" "start_cmd@v8.4.0" "" "start_cmd@v8.4.0.pl" "full_replace"
apply_payload "packages/cli/src/commands/chb.ts" "cmd_chb@v8.4.0" "" "cmd_chb@v8.4.0.pl" "create"

# 4.5 COMMANDS (v8.4.2 Refinements)
apply_payload "packages/cli/src/commands/blog.ts" "blog_orchestrator@v8.4.2" "" "blog_orchestrator.pl" "full_replace"
apply_payload "packages/cli/src/commands/close.ts" "close_cmd@v8.4.2" "" "close_cmd.pl" "full_replace"

# 5. REGISTRY & ENTRY
apply_payload "packages/cli/src/commands/index.ts" "index_cumulative@v8.4.0" "" "index_cumulative@v8.4.0.pl" "full_replace"
apply_payload "packages/cli/src/pulse.ts" "cmd_pulse@v8.4.0" "" "cmd_pulse@v8.4.0.pl" "full_replace"

# 6. SYNTAX GUARD
echo "🛡️ Running Syntax Guard..."
cd "$PULSE_PATH"
if command -v bun &> /dev/null; then
  bun install --silent
  if bun build ./packages/cli/src/pulse.ts --outdir ./dist --target bun > /tmp/bun_build.log 2>&1; then
    echo "✅ Syntax Guard PASSED."
  else
    echo "❌ Syntax Guard FAILED. Check /tmp/bun_build.log"
    cat /tmp/bun_build.log
    exit 1
  fi
fi

echo "✅ MASTER Patch v8.4.2 Applied successfully."
