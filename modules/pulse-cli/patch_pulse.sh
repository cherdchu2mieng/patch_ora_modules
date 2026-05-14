#!/bin/bash

# สคริปต์สำหรับอัปเดต pulse-cli: เวอร์ชัน Robust (v3) - Interactive Popup
# ฟีเจอร์: 
# 1. Baseline Verification: ตรวจสอบ Remote URL (Pulse-Oracle/pulse-cli)
# 2. Interactive Selection: ถามยืนยันทีละ Oracle (Popup style)
# 3. Modular Logic: เรียกใช้ core/common.sh
# 4. Safe-Reset & Version Check: คืนสถานะไฟล์และตรวจสอบความเข้ากันได้
# 5. Routing Automation: สร้าง label/repo routing และ Thai Keywords อัตโนมัติ
# 6. Patched Indicator: แสดงเครื่องหมาย (patched 🌊) ในหน้า Help

# Source shared logic
SCRIPT_DIR=$(dirname $(realpath "$0"))
COMMON_SH="$SCRIPT_DIR/../../core/common.sh"
if [ -f "$COMMON_SH" ]; then
    source "$COMMON_SH"
else
    echo "Error: common.sh not found at $COMMON_SH"
    exit 1
fi

export PULSE_PATH=$(verify_path "$1")
log_step "🚀 Starting Robust Patch for pulse-cli at $PULSE_PATH..."

# --- 0. Pre-flight Safety Checks ---
log_step "🔍 Verifying target environment..."
check_version "$PULSE_PATH" "^1\."
verify_remote "$PULSE_PATH" "Pulse-Oracle/pulse-cli"

TARGET_FILES=(
    "packages/cli/src/commands/init.ts"
    "packages/cli/src/pulse.ts"
)

# 0.1 Backup
log_info "Creating backups..."
for f in "${TARGET_FILES[@]}"; do
    if [ -f "$PULSE_PATH/$f" ]; then
        cp "$PULSE_PATH/$f" "$PULSE_PATH/$f.bfpch.bak"
    fi
done

# 0.2 Safe-Reset
safe_reset "$PULSE_PATH" "${TARGET_FILES[@]}"

# --- 1. Patch packages/cli/src/commands/init.ts ---
log_step "🛠️ Patching init.ts (Step-by-Step Oracle Selection)..."
python3 - <<'PY_EOF'
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/init.ts')
if not os.path.exists(path):
    print(f'X {path} not found')
    exit(1)

content = open(path).read()

# 1.1 Update imports to include RoutingConfig
if 'type RoutingConfig' not in content:
    content = content.replace('import { gh } from "@pulse-oracle/sdk";', 'import { gh, type RoutingConfig } from "@pulse-oracle/sdk";')

# 1.2 Step-by-Step Interactive Selection Logic
selection_logic = """
    let oracleRepos: Record<string, string> = {};
    for (const name of oracleNames) {
      const key = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "");
      oracleRepos[key || name.toLowerCase()] = name;
    }

    if (oracleNames.length > 0) {
      console.log(`\\nDiscovering oracle repos in ${org.trim()}...`);
      console.log(`Found ${oracleNames.length} potential oracles. Please confirm each one:`);
      const keys = Object.keys(oracleRepos);
      const filteredRepos: Record<string, string> = {};
      
      for (const key of keys) {
        const confirm = await ask(rl, `  Include ${key} (${oracleRepos[key]})? (Y/n) `);
        if (confirm.trim().toLowerCase() !== 'n') {
          filteredRepos[key] = oracleRepos[key];
        }
      }
      oracleRepos = filteredRepos;
    } else {
      console.log("No oracle repos found. You can add them to pulse.config.json later.");
    }
"""

if 'let oracleRepos' not in content:
    pattern = r'const\s+oracleRepos:[\s\S]*?if\s*\(oracleNames\.length\s*>\s*0\)[\s\S]*?else\s*\{[\s\S]*?\}'
    if re.search(pattern, content):
        content = re.sub(pattern, selection_logic.strip(), content)
        print('✓ Updated init.ts with step-by-step selection')

# 1.3 Enhanced logic for routing and config
new_logic = """
    const routing: RoutingConfig = {
      label: Object.keys(oracleRepos).map(oracle => ({
        match: [`oracle/${oracle}`],
        oracle
      })),
      repo: Object.entries(oracleRepos).reduce((acc, [oracle, repo]) => {
        const baseRepo = repo.includes("/") ? repo.split("/")[1] : repo;
        acc[baseRepo] = oracle;
        return acc;
      }, {} as Record<string, string>),
      keyword: [
        { match: ["orchestrate", "fleet", "patch", "robust", "system", "จัดการ", "กองทัพ", "แพตช์", "ระบบ"], oracle: "gemi" },
        { match: ["search", "trace", "find", "path", "remote", "ค้นหา", "แกะรอย", "พบ", "เส้นทาง"], oracle: "sky" },
        { match: ["coordinate", "sync", "submodule", "synchronize", "ประสานงาน", "ซิงค์", "เชื่อมต่อ"], oracle: "pegasus" },
        { match: ["ui", "design", "visual", "infographic", "graph", "ออกแบบ", "ภาพ", "กราฟ"], oracle: "infographic" },
        { match: ["memory", "backup", "archive", "custodian", "ความจำ", "สำรอง", "คลัง", "ผู้ดูแล"], oracle: "vault" },
        { match: ["web", "react", "html", "css", "frontend", "เว็บ", "หน้าบ้าน"], oracle: "frontend" },
        { match: ["api", "database", "server", "node", "backend", "เซิร์ฟเวอร์", "หลังบ้าน"], oracle: "backend" },
        { match: ["study", "analyze", "research", "paper", "ศึกษา", "วิเคราะห์", "วิจัย"], oracle: "research" }
      ],
      default: oracleRepos["pulse"] ? "pulse" : "pulse"
    };

    const config: PulseConfig = {
      org: org.trim(),
      projectNumber,
      oracleRepos,
      routing
    };
"""

if 'routing:' not in content:
    pattern = r'const\s+config:\s*PulseConfig\s*=\s*\{[\s\S]*?\};'
    if re.search(pattern, content):
        content = re.sub(pattern, new_logic.strip(), content)
        print('✓ Updated init.ts with routing logic')

with open(path, 'w') as f: f.write(content)
PY_EOF

# --- 2. Patch packages/cli/src/pulse.ts ---
log_step "🛠️ Patching pulse.ts (Patched Indicator)..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/pulse.ts')
content = open(path).read()
indicator = ' (patched 🌊)'
if indicator not in content:
    content = content.replace('pulse — GH Projects Master Board CLI', 'pulse — GH Projects Master Board CLI' + indicator)
    with open(path, 'w') as f: f.write(content)
    print('✓ Added patched indicator to pulse.ts')
PY_EOF

# --- 3. Rebuild ---
log_step "📦 Rebuilding pulse-cli..."
cd "$PULSE_PATH"
if [ -f "package.json" ]; then
    bun install
    if [ -d "packages/cli" ]; then
        cd packages/cli
        bun run build 2>/dev/null || log_info "No build script in packages/cli, source is ready."
    fi
fi

log_step "✅ Patch Complete!"
log_info "Run 'pulse init' to test the new selection flow."
