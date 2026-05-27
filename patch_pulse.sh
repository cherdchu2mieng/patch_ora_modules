#!/bin/bash
# Pulse Patch Orchestrator v8.4.0 (Ironclad v2.1)
# Sequential, Manifest-Driven, Idempotent

if [ -z "$1" ]; then
  echo "Usage: $0 <pulse-cli-path> [--restore]"
  exit 1
fi

export PULSE_PATH=$(realpath "$1")
export PAYLOADS_DIR="$(dirname "$0")/payloads"
echo "🌊 Applying MASTER Patch v8.4.0 (Ironclad v2.1) to $PULSE_PATH..."

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
  "packages/cli/src/commands/close.ts"
  "packages/cli/src/commands/index.ts"
  "packages/cli/src/commands/set.ts"
  "packages/cli/src/commands/start.ts"
  "packages/cli/src/commands/triage.ts"
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
  local anchor="$3"
  local payload_name="$4"
  local mode="${5:-replace}"

  echo "🛠️  Checking $feature in $(basename "$target_file")..."
  
  python3 - <<PY_EOF
import os, sys

path = os.path.join(os.environ['PULSE_PATH'], '$target_file')
payload_path = os.path.join(os.environ['PAYLOADS_DIR'], '$payload_name')

if not os.path.exists(path):
    print(f"  ⚠️ Skipping: {path} not found")
    sys.exit(0)

with open(path, 'r') as f:
    content = f.read()

tag = "$feature"
if f"// @pulse-patch: {tag}" in content:
    print(f"  ✅ {tag} already present.")
    sys.exit(0)

if not os.path.exists(payload_path):
    print(f"  ❌ Error: Payload file not found: {payload_path}")
    sys.exit(1)

with open(payload_path, 'r') as f:
    payload = f.read().strip()

# Manifest Management
manifest_line = f"// @pulse-patch: {tag}"
if "// @pulse-patch:" in content:
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if line.startswith("// @pulse-patch:"):
            if tag not in line:
                lines[i] = line.rstrip() + f" {tag}"
            break
    content = '\n'.join(lines)
else:
    lines = content.split('\n')
    if lines[0].startswith("#!"):
        content = lines[0] + "\n" + manifest_line + "\n" + '\n'.join(lines[1:])
    else:
        content = f"{manifest_line}\n" + content

# Injection
anchor = r'''$anchor'''
if '$mode' == 'replace':
    if anchor in content:
        content = content.replace(anchor, payload + "\n" + anchor)
    else:
        print(f"  ❌ Error: Anchor not found in $target_file")
        print(f"  Anchor: {anchor}")
        sys.exit(1)

with open(path, 'w') as f:
    f.write(content)
print(f"  ✨ Applied {tag}")
PY_EOF

  if [ $? -ne 0 ]; then
    echo "❌ Patch FAILED on $feature."
    exit 1
  fi
}

# 3. SEQUENTIAL PATCHING
# CR-PULSE-ALIGN-001: Add Command
apply_payload "packages/cli/src/commands/add.ts" "add_imports@v8.4.0" "import { gh," "add_imports@v8.4.0.pl"
apply_payload "packages/cli/src/commands/add.ts" "add_config_logic@v8.4.0" "const ctx = getContext();" "add_config_logic@v8.4.0.pl"
apply_payload "packages/cli/src/commands/add.ts" "add_status_enforcement@v8.4.0" "return addedItemId;" "add_status_enforcement@v8.4.0.pl"
apply_payload "packages/cli/src/pulse.ts" "pulse_add_syntax@v8.4.0" "  case \"add\":" "pulse_add_syntax@v8.4.0.pl"

# 5. SYNTAX GUARD
echo "🛡️ Running Syntax Guard..."
cd "$PULSE_PATH"
if command -v bun &> /dev/null; then
  bun install --silent
  if bun build ./packages/cli/src/pulse.ts --outdir ./dist --target bun > /dev/null 2>&1; then
    echo "✅ Syntax Guard PASSED."
  else
    echo "❌ Syntax Guard FAILED. Reverting changes..."
    git checkout -- .
    exit 1
  fi
fi

echo "✅ MASTER Patch v8.4.0 (Part 1: CR-001) Applied successfully."
