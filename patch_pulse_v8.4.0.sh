#!/bin/bash
# Pulse Patch Orchestrator v8.4.0 (Ironclad v2.2)
# Sequential, Manifest-Driven, Idempotent

if [ -z "$1" ]; then
  echo "Usage: $0 <pulse-cli-path> [--restore]"
  exit 1
fi

export PULSE_PATH=$(realpath "$1")
export PAYLOADS_DIR="$(dirname "$0")/modules/pulse-cli/payloads"
echo "🌊 Applying MASTER Patch v8.4.0 (Ironclad v2.2) to $PULSE_PATH..."

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
  "packages/cli/src/config.ts"
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

if not os.path.exists(path):
    print(f"  ⚠️ Skipping: {path} not found")
    sys.exit(0)

with open(path, "r") as f:
    content = f.read()

# Robust Manifest Check
manifest_match = re.search(r"^// @pulse-patch:.*", content, re.MULTILINE)
if manifest_match:
    manifest_line = manifest_match.group(0)
    if tag in manifest_line.split():
        print(f"  ✅ {tag} already present.")
        sys.exit(0)

if not os.path.exists(payload_path):
    print(f"  ❌ Error: Payload file not found: {payload_path}")
    sys.exit(1)

with open(payload_path, "r") as f:
    payload = f.read().strip()

# Manifest Management
if manifest_match:
    lines = content.split("\n")
    for i, line in enumerate(lines):
        if line.startswith("// @pulse-patch:"):
            if tag not in line.split():
                lines[i] = line.rstrip() + f" {tag}"
            break
    content = "\n".join(lines)
else:
    lines = content.split("\n")
    if lines[0].startswith("#!"):
        content = lines[0] + "\n" + f"// @pulse-patch: {tag}" + "\n" + "\n".join(lines[1:])
    else:
        content = f"// @pulse-patch: {tag}\n" + content

# Injection
if mode == "replace_block":
    if start in content and end in content:
        parts = content.split(start, 1)
        post_parts = parts[1].split(end, 1)
        content = parts[0] + payload + "\n  " + end + post_parts[1]
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

# 2.5 CORE INFRASTRUCTURE
apply_payload "packages/cli/src/config.ts" "config_orchestrator_field@v8.4.0" "  repoName?: string;" "config_orchestrator_field@v8.4.0.pl"
apply_payload "packages/cli/src/config.ts" "config_get_current_oracle@v8.2.1" "export function getContext()" "config_get_current_oracle@v8.2.1.pl"

# 3. SEQUENTIAL PATCHING (CR-001)
apply_payload "packages/cli/src/commands/add.ts" "add_imports@v8.4.0" "import { gh," "add_imports@v8.4.0.pl" "replace_line"
apply_payload "packages/cli/src/commands/add.ts" "add_config_logic@v8.4.0" "const ctx = getContext();" "add_config_logic@v8.4.0.pl"
apply_payload "packages/cli/src/commands/add.ts" "add_field_sync@v8.4.0" "return addedItemId;" "add_field_sync@v8.4.0.pl"
apply_payload "packages/cli/src/pulse.ts" "pulse_add_syntax@v8.4.0" '  case "add":' "pulse_add_syntax@v8.4.0.pl" "replace_block" '  case "set":'

# 4. SEQUENTIAL PATCHING (CR-002)
apply_payload "packages/cli/src/commands/board.ts" "board_config_check@v8.4.0" "const allItems =" "board_config_check@v8.4.0.pl"
apply_payload "packages/cli/src/commands/triage.ts" "triage_config_check@v8.4.0" "const items =" "triage_config_check@v8.4.0.pl"
apply_payload "packages/cli/src/commands/triage.ts" "triage_authority_gate@v8.4.0" "const items =" "triage_authority_gate@v8.4.0.pl"

# 5. SYNTAX GUARD
echo "🛡️ Running Syntax Guard..."
cd "$PULSE_PATH"
if command -v bun &> /dev/null; then
  bun install --silent
  if bun build ./packages/cli/src/pulse.ts --outdir ./dist --target bun > /dev/null 2>&1; then
    echo "✅ Syntax Guard PASSED."
  else
    echo "❌ Syntax Guard FAILED. Reverting changes..."
    exit 1
  fi
fi

echo "✅ MASTER Patch v8.4.0 Applied successfully."
