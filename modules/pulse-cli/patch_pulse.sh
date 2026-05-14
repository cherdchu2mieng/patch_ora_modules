#!/bin/bash

# สคริปต์สำหรับอัปเดต pulse-cli: เวอร์ชัน Robust (v2)
# ฟีเจอร์: 
# 1. Modular Logic: เรียกใช้ core/common.sh สำหรับความปลอดภัย
# 2. Safe-Reset & Version Check: คืนสถานะไฟล์และตรวจสอบความเข้ากันได้
# 3. Interactive Selection: เลือก Oracle ที่ต้องการรวมในคอนฟิกได้
# 4. Routing Automation: สร้าง label/repo routing และ Thai Keywords อัตโนมัติ
# 5. Patched Indicator: แสดงเครื่องหมาย (patched 🌊) ในหน้า Help
# 6. Backup Support: บันทึกไฟล์เดิมก่อนทำการแก้ไข

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
log_step "🛠️ Patching init.ts (Interactive Selection & Routing)..."
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

# 1.2 Interactive Selection Logic
selection_logic = """
    let oracleRepos: Record<string, string> = {};
    for (const name of oracleNames) {
      const key = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "");
      oracleRepos[key || name.toLowerCase()] = name;
    }

    if (oracleNames.length > 0) {
      console.log(`\\nFound ${oracleNames.length} oracle repos:`);
      const keys = Object.keys(oracleRepos);
      for (let i = 0; i < keys.length; i++) {
        console.log(`  [${i}] ${keys[i]} => ${oracleRepos[keys[i]]}`);
      }
      const selection = await ask(rl, `\\nSelect oracles to include (indices separated by comma, or Enter for all): `);
      if (selection.trim()) {
        const selectedIndices = selection.split(",").map(s => parseInt(s.trim())).filter(n => !isNaN(n));
        const filteredRepos: Record<string, string> = {};
        for (const idx of selectedIndices) {
          const k = keys[idx];
          if (k) filteredRepos[k] = oracleRepos[k];
        }
        oracleRepos = filteredRepos;
      }
    } else {
      console.log("No oracle repos found. You can add them to pulse.config.json later.");
    }
"""

if 'let oracleRepos' not in content:
    pattern = r'const\s+oracleRepos:[\s\S]*?if\s*\(oracleNames\.length\s*>\s*0\)[\s\S]*?else\s*\{[\s\S]*?\}'
    if re.search(pattern, content):
        content = re.sub(pattern, selection_logic.strip(), content)
        print('✓ Updated init.ts with interactive selection')

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
else:
    print('i pulse.ts already has patched indicator')
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
log_info "Run 'pulse --help' to verify."
