#!/bin/bash

# สคริปต์สำหรับอัปเดต pulse-cli: เวอร์ชัน Multi-Org Support & Metadata (v7.6)

SCRIPT_DIR=$(dirname $(realpath "$0"))
COMMON_SH="$SCRIPT_DIR/../../core/common.sh"
if [ -f "$COMMON_SH" ]; then source "$COMMON_SH"; else exit 1; fi

export PULSE_PATH=$(verify_path "$1")
log_step "🚀 Starting Metadata Patch (v7.6) for pulse-cli..."

TARGET_FILES=(
    "packages/sdk/src/types.ts"
    "packages/sdk/src/github.ts"
    "packages/cli/src/pulse.ts"
    "packages/cli/src/commands/add.ts"
)

# 0.1 Backup & Safe-Reset
for f in "${TARGET_FILES[@]}"; do [ -f "$PULSE_PATH/$f" ] && cp "$PULSE_PATH/$f" "$PULSE_PATH/$f.v76.bak"; done
safe_reset "$PULSE_PATH" "${TARGET_FILES[@]}"

# --- 1. Patch packages/sdk/src/types.ts ---
log_step "🛠️ Patching SDK types.ts..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/sdk/src/types.ts')
content = open(path).read()
if 'client?: string;' not in content:
    content = content.replace('priority?: string;', 'priority?: string;\n  client?: string;')
    open(path, 'w').write(content)
PY_EOF

# --- 2. Patch packages/sdk/src/github.ts ---
log_step "🛠️ Patching SDK github.ts..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/sdk/src/github.ts')
content = open(path).read()
if 'export async function setFieldOnItem' not in content:
    content = content.replace('async function setFieldOnItem', 'export async function setFieldOnItem')
    open(path, 'w').write(content)
PY_EOF

# --- 3. Patch packages/cli/src/pulse.ts ---
log_step "🛠️ Patching pulse.ts (Advanced Add Syntax)..."
python3 - <<'PY_EOF'
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/pulse.ts')
content = open(path).read()

# Update version
content = re.sub(r'v7\.4\.[0-9]+', 'v7.6', content)
content = re.sub(r'v7\.5', 'v7.6', content)

# Implementation of Advanced Add Syntax
add_impl = """  case "add":
  case "a": {
    let titleIndex = 0;
    let isOrg = args[0] === "org";
    if (isOrg) titleIndex = 1;

    const title = args[titleIndex];
    if (!title || title.startsWith("--")) {
      console.error("Usage: pulse add [org] <title> [body] [--oracle <name>] [--priority <P0-P3>] [--client <name>]");
      process.exit(1);
    }

    // Body is the next argument if it is not a flag
    let body = parseFlag("--body");
    if (!body && args[titleIndex + 1] && !args[titleIndex + 1].startsWith("--")) {
      body = args[titleIndex + 1];
    }

    const opts: any = {
      body,
      oracle: parseFlag("--oracle"),
      repo: parseFlag("--repo"),
      type: parseFlag("--type"),
      priority: parseFlag("--priority"),
      client: parseFlag("--client"),
      wt: parseFlag("--wt"),
      worktree: args.includes("--worktree"),
    };

    // Org mode defaults
    if (isOrg) {
      if (!opts.oracle) opts.oracle = "it49072";
      if (!opts.priority) opts.priority = "P2";
      if (!opts.client) opts.client = "IT Board Team";
      if (!opts.repo) opts.repo = "itinfosv/it49072-oracle";
    }

    await add(title, opts);
    break;
  }"""

start_marker = '  case "add":'
end_marker = '    break;\n  }'
if start_marker in content:
    # Find the block carefully
    parts = content.split(start_marker)
    after_add = parts[1].split(end_marker, 1)
    content = parts[0] + add_impl + after_add[1]

open(path, 'w').write(content)
PY_EOF

# --- 4. Patch packages/cli/src/commands/add.ts ---
log_step "🛠️ Patching add.ts..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/add.ts')
content = open(path).read()

# Imports
if 'setFieldOnItem' not in content:
    content = content.replace('import { gh,', 'import { gh, setFieldOnItem,')

# Target Repo Logic for Cross-Org
content = content.replace('if (!targetRepo) targetRepo = `${ctx.org}/pulse-oracle`;', 
                         'if (targetRepo && !targetRepo.includes("/")) targetRepo = `${ctx.org}/${targetRepo}`;\n  if (!targetRepo) targetRepo = `${ctx.org}/pulse-oracle`;')

# Client Metadata Logic
client_logic = """
  // Set Client metadata if specified
  if (opts.client) {
    try {
      await setFieldOnItem(ctx, addedItemId, "Client", opts.client);
      console.log(`Client: ${opts.client}`);
    } catch (e) {
      console.log(`Client: failed to set (${opts.client})`);
    }
  }
"""
if 'if (opts.client)' not in content:
    content = content.replace('return addedItemId;', client_logic + '\n  return addedItemId;')

open(path, 'w').write(content)
PY_EOF

log_step "✅ Patch Preparation Complete (v7.6)!"
