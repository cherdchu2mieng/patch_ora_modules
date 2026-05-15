#!/bin/bash

# สคริปต์สำหรับอัปเดต pulse-cli: เวอร์ชัน Dynamic Gateway Configuration (v7.7)

SCRIPT_DIR=$(dirname $(realpath "$0"))
COMMON_SH="$SCRIPT_DIR/../../core/common.sh"
if [ -f "$COMMON_SH" ]; then source "$COMMON_SH"; else exit 1; fi

export PULSE_PATH=$(verify_path "$1")
log_step "🚀 Starting Dynamic Gateway Patch (v7.7) for pulse-cli..."

TARGET_FILES=(
    "packages/sdk/src/types.ts"
    "packages/cli/src/config.ts"
    "packages/cli/src/commands/init.ts"
    "packages/cli/src/pulse.ts"
)

# 0.1 Backup & Safe-Reset
for f in "${TARGET_FILES[@]}"; do [ -f "$PULSE_PATH/$f" ] && cp "$PULSE_PATH/$f" "$PULSE_PATH/$f.v77.bak"; done
safe_reset "$PULSE_PATH" "${TARGET_FILES[@]}"

# --- 1. Patch packages/sdk/src/types.ts ---
log_step "🛠️ Patching SDK types.ts..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/sdk/src/types.ts')
content = open(path).read()
if 'gateway?: { repo: string; oracle: string; client: string; priority: string };' not in content:
    content = content.replace('projectNumber: number;', 'projectNumber: number;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };')
    open(path, 'w').write(content)
PY_EOF

# --- 2. Patch packages/cli/src/config.ts ---
log_step "🛠️ Patching CLI config.ts..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/config.ts')
content = open(path).read()

# Add to PulseConfig interface
if 'gateway?: {' not in content:
    content = content.replace('oracleRepos: Record<string, string>;', 'oracleRepos: Record<string, string>;\n  gateway?: { repo: string; oracle: string; client: string; priority: string };')

# Update getContext()
content = content.replace('return { org: cfg.org, projectNumber: cfg.projectNumber };', 
                         'return { org: cfg.org, projectNumber: cfg.projectNumber, gateway: cfg.gateway };')

open(path, 'w').write(content)
PY_EOF

# --- 3. Patch packages/cli/src/commands/init.ts ---
log_step "🛠️ Patching CLI init.ts..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/init.ts')
content = open(path).read()

# Add prompts
prompt_logic = """    if (!org.trim() || isNaN(projectNumber)) {
      console.error(\"Invalid org or project number.\");
      return;
    }

    let gateway;
    if (isOrg) {
      console.log(\"\\n🌐 Gateway Configuration (Required for Org Mode)\");
      const gRepo = await ask(rl, \"Gateway Repo (e.g. itinfosv/it49072-oracle): \");
      const gOracle = await ask(rl, \"Gateway Oracle (e.g. pegasus): \");
      const gClient = await ask(rl, \"Gateway Client (e.g. IT Board Team): \");
      const gPriority = await ask(rl, \"Gateway Priority (e.g. P2): \");
      gateway = { repo: gRepo.trim(), oracle: gOracle.trim(), client: gClient.trim(), priority: gPriority.trim() };
    }"""

if 'let gateway;' not in content:
    content = content.replace('    if (!org.trim() || isNaN(projectNumber)) {\n      console.error(\"Invalid org or project number.\");\n      return;\n    }', prompt_logic)

# Add gateway to config object
if 'gateway,' not in content:
    content = content.replace('projectNumber,\n        oracleRepos,', 'projectNumber,\n        oracleRepos,\n        gateway,')

open(path, 'w').write(content)
PY_EOF

# --- 4. Patch packages/cli/src/pulse.ts ---
log_step "🛠️ Patching pulse.ts (Dynamic Gateway Logic)..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/pulse.ts')
content = open(path).read()

# Add import
if 'import { getContext }' not in content:
    content = content.replace('import { board', 'import { getContext } from "./config";\nimport { board')

# Version update
content = content.replace('GH Projects Master Board CLI', 'GH Projects Master Board CLI (patched 🌊 v7.7)')

# Dynamic Gateway Logic replacement
old_block = """    // Org mode defaults
    if (isOrg) {
      if (!opts.oracle) opts.oracle = \"pegasus\";
      if (!opts.priority) opts.priority = \"P2\";
      if (!opts.client) opts.client = \"IT Board Team\";
      if (!opts.repo) opts.repo = \"itinfosv/it49072-oracle\";
    }"""

new_block = """    const ctx = getContext();
    // Org mode dynamic defaults
    if (isOrg) {
      const gateway = (ctx as any).gateway;
      if (gateway) {
        if (!opts.oracle) opts.oracle = gateway.oracle;
        if (!opts.priority) opts.priority = gateway.priority;
        if (!opts.client) opts.client = gateway.client;
        if (!opts.repo) opts.repo = gateway.repo;
      } else {
        console.error(\"Error: Gateway configuration missing. Run 'pulse init' or add 'gateway' to config.\");
        process.exit(1);
      }
    }"""

if old_block in content:
    content = content.replace(old_block, new_block)
elif 'const gateway = (ctx as any).gateway;' not in content:
    # Fallback if old block is slightly different or already partially patched
    print("Warning: Could not find exact old_block in pulse.ts, manual check might be needed.")

open(path, 'w').write(content)
PY_EOF

log_step "✅ Dynamic Gateway Patch Complete (v7.7)!"
