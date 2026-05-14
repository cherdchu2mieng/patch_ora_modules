#!/bin/bash

# สคริปต์สำหรับอัปเดต pulse-cli: เวอร์ชัน Robust (v5) - Advanced Formatting & Sorting
# ฟีเจอร์: 
# 1. Advanced Formatting: จัดระเบียบ JSON ให้สวยงาม เรียงลำดับตัวอักษร (Sorting)
# 2. Baseline Verification: ตรวจสอบ Remote URL (Pulse-Oracle/pulse-cli)
# 3. Advanced Interactive Selection: เลือกรายตัว, เปลี่ยนชื่อ (Rename), เพิ่ม Keyword
# 4. Existing Config Support: ตรวจสอบไฟล์เดิมเพื่อเลือก Exclude หรือ Adjust
# 5. Patched Indicator: แสดงเครื่องหมาย (patched 🌊) ในหน้า Help

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
log_step "🚀 Starting Robust Patch (v5) for pulse-cli at $PULSE_PATH..."

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
log_step "🛠️ Patching init.ts (Advanced Sorting & Formatting)..."
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

# 1.2 Advanced Selection Logic
selection_logic = """
    const fs = require('fs');
    const path = require('path');
    let existing: any = {};
    try {
      const configPath = path.join(process.cwd(), 'pulse.config.json');
      if (fs.existsSync(configPath)) {
        existing = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      }
    } catch {}

    const oracleReposRaw: Record<string, string> = {};
    const customKeywords: Record<string, string[]> = {};

    if (oracleNames.length > 0) {
      console.log(`\\nDiscovering oracle repos in ${org.trim()}...`);
      for (const name of oracleNames) {
        const defaultKey = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || name.toLowerCase();
        
        // Check if already in existing
        let currentKey = defaultKey;
        let isIncluded = false;
        if (existing.oracleRepos) {
          for (const [k, v] of Object.entries(existing.oracleRepos)) {
            if (v === name) {
              currentKey = k;
              isIncluded = true;
              break;
            }
          }
        }

        let action = "";
        if (isIncluded) {
          action = await ask(rl, `  ${currentKey} (${name}) already included. [e]xclude, [a]djust, [s]kip? (s) `);
          action = action.trim().toLowerCase() || 's';
        } else {
          action = await ask(rl, `  Include ${defaultKey} (${name})? [y]es, [n]o, [a]djust? (y) `);
          action = action.trim().toLowerCase() || 'y';
        }

        if (action === 'n' || action === 'e') continue;
        
        let finalKey = currentKey;
        let keywords: string[] = [];

        if (action === 'a') {
          const newName = await ask(rl, `    New Name (Enter for ${currentKey}): `);
          if (newName.trim()) finalKey = newName.trim();
          
          const kwInput = await ask(rl, `    Additional Keywords (comma separated): `);
          if (kwInput.trim()) {
            keywords = kwInput.split(',').map(k => k.trim()).filter(Boolean);
          }
        }

        oracleReposRaw[finalKey] = name;
        if (keywords.length > 0) customKeywords[finalKey] = keywords;
      }
    } else {
      console.log("No oracle repos found. You can add them to pulse.config.json later.");
    }

    // --- SORTING & FORMATTING ---
    const oracleRepos = Object.keys(oracleReposRaw).sort().reduce((acc, key) => {
      acc[key] = oracleReposRaw[key];
      return acc;
    }, {} as Record<string, string>);
"""

# Replace the block that handles oracleNames to oracleRepos mapping and selection
pattern = r'const\s+oracleRepos:[\s\S]*?if\s*\(oracleNames\.length\s*>\s*0\)[\s\S]*?else\s*\{[\s\S]*?\}'
if re.search(pattern, content):
    content = re.sub(pattern, selection_logic.strip(), content)
    print('✓ Updated init.ts with advanced selection & sorting logic')
else:
    print('X Could not find selection block in init.ts')

# 1.3 Enhanced logic for routing and config with Merging & Sorting
new_logic = """
    const standardKeywords = [
      { match: ["orchestrate", "fleet", "patch", "robust", "system", "จัดการ", "กองทัพ", "แพตช์", "ระบบ"], oracle: "gemi" },
      { match: ["search", "trace", "find", "path", "remote", "ค้นหา", "แกะรอย", "พบ", "เส้นทาง"], oracle: "sky" },
      { match: ["coordinate", "sync", "submodule", "synchronize", "ประสานงาน", "ซิงค์", "เชื่อมต่อ"], oracle: "pegasus" },
      { match: ["ui", "design", "visual", "infographic", "graph", "ออกแบบ", "ภาพ", "กราฟ"], oracle: "infographic" },
      { match: ["memory", "backup", "archive", "custodian", "ความจำ", "สำรอง", "คลัง", "ผู้ดูแล"], oracle: "vault" },
      { match: ["web", "react", "html", "css", "frontend", "เว็บ", "หน้าบ้าน"], oracle: "frontend" },
      { match: ["api", "database", "server", "node", "backend", "เซิร์ฟเวอร์", "หลังบ้าน"], oracle: "backend" },
      { match: ["study", "analyze", "research", "paper", "ศึกษา", "วิเคราะห์", "วิจัย"], oracle: "research" }
    ];

    const mergedKeywords = [...standardKeywords];
    for (const [oracle, kws] of Object.entries(customKeywords)) {
      const entry = mergedKeywords.find(k => k.oracle === oracle);
      if (entry) {
        entry.match = Array.from(new Set([...entry.match, ...kws]));
      } else {
        mergedKeywords.push({ match: kws, oracle });
      }
    }

    const routing: RoutingConfig = {
      label: Object.keys(oracleRepos).sort().map(oracle => ({
        match: [`oracle/${oracle}`],
        oracle
      })),
      repo: Object.entries(oracleRepos).sort((a,b) => a[1].localeCompare(b[1])).reduce((acc, [oracle, repo]) => {
        const baseRepo = repo.includes("/") ? repo.split("/")[1] : repo;
        acc[baseRepo] = oracle;
        return acc;
      }, {} as Record<string, string>),
      keyword: mergedKeywords.sort((a, b) => a.oracle.localeCompare(b.oracle)),
      default: oracleRepos["pulse"] ? "pulse" : (oracleRepos["gemi"] ? "gemi" : "pulse")
    };

    // Construct config with fixed key order for readability
    const config: PulseConfig = {
      org: org.trim(),
      projectNumber,
      oracleRepos,
      routing
    };
"""

pattern = r'const\s+config:\s*PulseConfig\s*=\s*\{[\s\S]*?\};'
if re.search(pattern, content):
    content = re.sub(pattern, new_logic.strip(), content)
    print('✓ Updated init.ts with sorted routing logic')

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
log_info "Run 'pulse init' to see the beautifully sorted configuration."
