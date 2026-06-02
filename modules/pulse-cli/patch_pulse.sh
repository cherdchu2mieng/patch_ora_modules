#!/bin/bash
# Pulse Patch Orchestrator v8.5 (v2.5 Standard)
# Sequential, Manifest-Driven, Idempotent, Clean-First

if [ -z "$1" ]; then
  echo "Usage: $0 <pulse-cli-path> [--restore]"
  exit 1
fi

export PULSE_PATH=$(realpath "$1")
export PAYLOADS_DIR="$(realpath "$(dirname "$0")/payloads")"

# 0. TARGET CLEAN (v2.5 Mandate)
echo "🧹 Cleaning Target Repo: $PULSE_PATH..."
cd "$PULSE_PATH" || exit 1
git fetch origin > /dev/null 2>&1
git reset --hard origin/main > /dev/null 2>&1
git clean -fd > /dev/null 2>&1

# 0.2 EMERGENCY BASELINE REPAIR (package.json corruption)
if grep -q "// @pulse-patch:" package.json; then
  echo "🩹 Repairing corrupted package.json baseline..."
  sed -i "/\/\/ @pulse-patch:/d" package.json
fi

echo "✅ Target is now Clean Baseline (Upstream + Local Fix)."

echo "🌊 Applying MASTER Patch v8.5.0 (Unified Protocol V1) to $PULSE_PATH..."

# 0.1 RESTORE LOGIC
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
  "packages/cli/src/config.ts"
  "packages/cli/src/commands/add.ts"
  "packages/cli/src/commands/blog.ts"
  "packages/cli/src/commands/chb.ts"
  "packages/cli/src/commands/init.ts"
  "packages/sdk/src/types.ts"
  "packages/sdk/src/github.ts"
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
is_json = target_file.endswith(".json")
if not is_json:
    manifest_match = re.search(r"// @pulse-patch:.*", content)
    if manifest_match and tag in manifest_match.group(0).split():
        print(f"  ✅ {tag} already present.")
        sys.exit(0)

if not os.path.exists(payload_path):
    print(f"  ❌ Error: Payload file not found: {payload_path}")
    sys.exit(1)

with open(payload_path, "r") as f:
    payload = f.read().strip()

# Manifest Management
if not is_json:
    if "// @pulse-patch:" in content:
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if line.startswith("// @pulse-patch:"):
                if tag not in line:
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
elif mode == "replace_file":
    content = payload
    if not is_json:
        content = f"// @pulse-patch: {tag}\n" + content
elif mode == "replace_line":
    if start in content:
        content = content.replace(start, payload)
    else:
        if payload in content:
            pass
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

# 3. BASELINE SEQUENTIAL PATCHING
apply_payload "packages/sdk/src/types.ts" "sdk_blog_opts@v8.4.2r6" "export interface BlogOpts {" "sdk_blog_opts@v8.4.2r6.pl" "replace_block" "}"

IMPORT_LINE="import { gh, getIssueTypes, setIssueType, setTextField, ensureLabel } from \"@pulse-oracle/sdk\";"
apply_payload "packages/cli/src/commands/add.ts" "add_imports@v8.4.0" "$IMPORT_LINE" "add_imports@v8.4.0.pl" "replace_line"
apply_payload "packages/cli/src/commands/add.ts" "add_config_imports@v8.4.0" "import { getContext, getOracleRepos } from \"../config\";" "add_config_imports@v8.4.0.pl" "replace_line"
apply_payload "packages/cli/src/commands/add.ts" "add_config_logic@v8.4.0" "const ctx = getContext();" "add_config_logic@v8.4.0.pl"

REPO_BLOCK_START="  let targetRepo = opts.repo;"
REPO_BLOCK_END="  if (!targetRepo) targetRepo = \`\${ctx.org}/pulse-oracle\`;"
apply_payload "packages/cli/src/commands/add.ts" "add_repo_lock@v8.4.0" "$REPO_BLOCK_START" "add_repo_lock@v8.4.0.pl" "replace_block" "$REPO_BLOCK_END"

apply_payload "packages/cli/src/commands/add.ts" "add_field_sync@v8.4.0" "return addedItemId;" "add_field_sync@v8.4.0.pl"

apply_payload "packages/cli/src/pulse.ts" "pulse_add_syntax@v8.4.0" "  case \"add\":" "pulse_add_syntax@v8.4.0.pl" "replace_block" "    break;
  }"

# 5. REFINEMENT: PROVENANCE URL & CONFIG (CR-006.v2)
apply_payload "packages/cli/src/config.ts" "config_patch_ws@v8.4.2r6" "  blog?: {" "config_patch_ws@v8.4.2r6.pl" "replace_line"

# 6. ORCHESTRATOR BROADCAST AUTHORITY (CR-006.v1 Refinement)
apply_payload "packages/cli/src/pulse.ts" "pulse_config_imports@v8.4.2r6" "import { board," "pulse_config_imports@v8.4.2r6.pl" "replace_line"
apply_payload "packages/cli/src/pulse.ts" "blog_authority_itb@v8.4.2r6" "const [cmd, ...args] = process.argv.slice(2);" "blog_authority_itb@v8.4.2r6.pl" "replace_line"

# Syntax Clean
BLOCK_START="case \"blog\": {"
BLOCK_END="    break;
  }"
apply_payload "packages/cli/src/pulse.ts" "blog_syntax_itb@v8.4.2r6" "$BLOCK_START" "blog_syntax_itb@v8.4.2r6.pl" "replace_block" "$BLOCK_END"

# Unified Target & Provenance logic
TARGET_START="  const blogRepo = cfg.blog?.repo || getRepoName();"
TARGET_END="  const discussion = await createDiscussion(org, blogRepo, title, fullBody, category);"
apply_payload "packages/cli/src/commands/blog.ts" "blog_target_itb@v8.4.2r6" "$TARGET_START" "blog_target_itb@v8.4.2r6.pl" "replace_block" "$TARGET_END"

# 8. SYNTAX GUARD
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


# 9. ITINFOSV REBRANDING (v8.5.0)
apply_payload "package.json" "rebrand_package@v8.5.0" "    \"url\": \"https://github.com/Pulse-Oracle/pulse-cli\"" "rebrand_package@v8.5.0.pl" "replace_line"
apply_payload ".github/workflows/inbox-auto-add.yml" "rebrand_workflow_issue@v8.5.0" "          maw hey pulse-oracle \"Issue closed: \${REPO} \${NUM} — \${TITLE} \${URL} — GitHub Actions\" || true" "rebrand_workflow_issue@v8.5.0.pl" "replace_line"
apply_payload ".github/workflows/inbox-auto-add.yml" "rebrand_workflow_pr@v8.5.0" "          # maw hey Pulse" "rebrand_workflow_pr@v8.5.0.pl" "replace_block" "          maw hey pulse-oracle \"PR merged: \${REPO} \${PR} — \${TITLE} (by \${AUTHOR}) \${URL} — GitHub Actions\" || true"
apply_payload "README.md" "rebrand_readme_clone@v8.5.0" "git clone https://github.com/Pulse-Oracle/pulse-cli" "rebrand_readme_clone@v8.5.0.pl" "replace_line"
apply_payload "README.md" "rebrand_readme_path@v8.5.0" "Pulse-Oracle/pulse-cli/" "rebrand_readme_path@v8.5.0.pl" "replace_line"

echo "✅ MASTER Patch v8.5.0 (Rebrand) Applied successfully."


# 4. CR-UNIFIED-002: pulse board V1 Visualization
apply_payload "packages/sdk/src/types.ts" "sdk_types_anchor@v8.5.0" "  repo: string;" "sdk_types_anchor@v8.5.0.pl" "replace_block" "}"
apply_payload "packages/sdk/src/github.ts" "sdk_github_anchor@v8.5.0" "            worktree: fieldValueByName(name: "Worktree") {" "sdk_github_anchor@v8.5.0.pl" "replace_block" "            }"
apply_payload "packages/sdk/src/github.ts" "sdk_github_mapping@v8.5.0" "    extraMap.set(node.id, {" "sdk_github_mapping@v8.5.0.pl" "replace_block" "    });"
apply_payload "packages/sdk/src/github.ts" "sdk_github_sync@v8.5.0" "    if (extra) {" "sdk_github_sync@v8.5.0.pl" "replace_block" "    }"
apply_payload "packages/cli/src/commands/board.ts" "cmd_board_v1@v8.5.0" "" "cmd_board_v1@v8.5.0.pl" "replace_file"

# 3. APPLY PAYLOADS (v8.5.0 Unified Protocol V1)
apply_payload "packages/cli/src/config.ts" "config_v1_interface@v8.5.0" "patchWorkspace?: string;" "config_v1_interface@v8.5.0.pl" "insert"
apply_payload "packages/cli/src/commands/init.ts" "init_v1_standard@v8.5.0" "" "init_v1_standard@v8.5.0.pl" "replace_file"

echo "✅ All patches applied for v8.5.0."
