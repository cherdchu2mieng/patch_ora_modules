#!/bin/bash
# Pulse Patch Orchestrator v8.2.1 (Ironclad v2.1)
# Sequential, Manifest-Driven, Idempotent

if [ -z "$1" ]; then
  echo "Usage: $0 <pulse-cli-path> [--restore]"
  exit 1
fi

export PULSE_PATH=$(realpath "$1")
export PAYLOADS_DIR="$(dirname "$0")/payloads"
echo "🌊 Applying MASTER Patch v8.2.1 (Ironclad v2.1) to $PULSE_PATH..."

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
  "packages/sdk/src/types.ts"
  "packages/sdk/src/github.ts"
  "packages/cli/src/config.ts"
  "packages/cli/src/commands/index.ts"
  "packages/cli/src/commands/add.ts"
  "packages/cli/src/pulse.ts"
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
  local mode="${5:-replace}" # replace or append

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

# Manifest Management (Ironclad v2.1)
manifest_line = f"// @pulse-patch: {tag}"
if "// @pulse-patch:" in content:
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if line.startswith("// @pulse-patch:"):
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
        print(f"  ❌ Error: Anchor not found in {target_file}")
        sys.exit(1)
elif '$mode' == 'append':
    content = content.rstrip() + "\n" + payload + "\n"

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
# SDK
apply_payload "packages/sdk/src/types.ts" "sdk_types@v8.2.1" "projectNumber: number;" "sdk_types@v8.2.1.pch" "replace"
apply_payload "packages/sdk/src/github.ts" "sdk_github_export@v8.2.1" "async function setFieldOnItem" "sdk_github_export@v8.2.1.pch" "replace"

# Config
apply_payload "packages/cli/src/config.ts" "config_interface@v8.2.1" "oracleRepos: Record<string, string>;" "config_interface@v8.2.1.pch" "replace"
apply_payload "packages/cli/src/config.ts" "config_get_current_oracle@v8.2.1" "export function getAllContexts()" "config_get_current_oracle@v8.2.1.pch" "replace"
apply_payload "packages/cli/src/config.ts" "config_get_context_return@v8.2.1" "return { org: cfg.org, projectNumber: cfg.projectNumber" "config_get_context_return@v8.2.1.pch" "replace"

# Add Command
apply_payload "packages/cli/src/commands/add.ts" "add_imports@v8.2.1" "import { getContext, getOracleRepos } from \"../config\";" "add_imports@v8.2.1.pch" "replace"
apply_payload "packages/cli/src/commands/add.ts" "add_current_oracle_check@v8.2.1" "const oracleLower = opts.oracle?.toLowerCase();" "add_current_oracle_check@v8.2.1.pch" "replace"
apply_payload "packages/cli/src/commands/add.ts" "add_routing_logic@v8.2.1" "let targetRepo = opts.repo;" "add_routing_logic@v8.2.1.pch" "replace"
apply_payload "packages/cli/src/commands/add.ts" "add_field_updates@v8.2.1" "return addedItemId;" "add_field_updates@v8.2.1.pch" "replace"

# Pulse Entry
apply_payload "packages/cli/src/pulse.ts" "pulse_imports@v8.2.1" "import { board" "pulse_imports@v8.2.1.pch" "replace"
apply_payload "packages/cli/src/pulse.ts" "pulse_enforce_auth@v8.2.1" "const [cmd, ...args]" "pulse_enforce_auth@v8.2.1.pch" "replace"
apply_payload "packages/cli/src/pulse.ts" "pulse_auth_call_set@v8.2.1" "case \"set\":\n  case \"s\":" "pulse_auth_call@v8.2.1.pch" "replace"
apply_payload "packages/cli/src/pulse.ts" "pulse_auth_call_triage@v8.2.1" "case \"triage\":\n  case \"tr\":" "pulse_auth_call@v8.2.1.pch" "replace"
apply_payload "packages/cli/src/pulse.ts" "pulse_command_cases@v8.2.1" "case \"set\":" "pulse_command_cases@v8.2.1.pch" "replace"
apply_payload "packages/cli/src/pulse.ts" "pulse_version_string@v8.2.1" "Pulse Oracle" "pulse_version_string@v8.2.1.pch" "replace"

# 4. COMMAND REGISTRY (New Files)
echo "📂 Creating command files..."
cp "$PAYLOADS_DIR/cmd_task@v8.2.1.pch" "$PULSE_PATH/packages/cli/src/commands/task.ts"
cp "$PAYLOADS_DIR/cmd_keyword@v8.2.1.pch" "$PULSE_PATH/packages/cli/src/commands/keyword.ts"
cp "$PAYLOADS_DIR/cmd_go@v8.2.1.pch" "$PULSE_PATH/packages/cli/src/commands/go.ts"
cp "$PAYLOADS_DIR/cmd_done@v8.2.1.pch" "$PULSE_PATH/packages/cli/src/commands/done.ts"

# Register in index.ts
python3 - <<EOF
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/index.ts')
with open(path, 'r') as f: content = f.read()
for cmd in ['keyword', 'task', 'go', 'done']:
    line = f'export {{ {cmd} }} from "./{cmd}";'
    if line not in content:
        content = content.strip() + f'\n{line}\n'
with open(path, 'w') as f: f.write(content)
EOF
echo "✓ Command index updated."

# 5. SYNTAX GUARD
echo "🛡️ Running Syntax Guard..."
cd "$PULSE_PATH"
if command -v bun &> /dev/null; then
  echo "📦 Installing dependencies (bun install)..."
  bun install --silent
  echo "🏗️  Building (bun build)..."
  if bun build ./packages/cli/src/pulse.ts --outdir ./dist --target bun > /tmp/bun_build.log 2>&1; then
    echo "✅ Syntax Guard PASSED."
  else
    echo "❌ Syntax Guard FAILED. Check /tmp/bun_build.log"
    exit 1
  fi
else
  echo "⚠️ Bun not found. Skipping automated Syntax Guard."
fi

echo "✅ MASTER Patch v8.2.1 Applied successfully."
