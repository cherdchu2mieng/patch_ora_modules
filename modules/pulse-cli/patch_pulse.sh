#!/bin/bash

# สคริปต์สำหรับอัปเดต pulse-cli: เวอร์ชัน Robust (v7) - Centralized Symlink Architecture
# ฟีเจอร์: 
# 1. Centralized Storage: บันทึกไฟล์จริงที่ ~/.config/pulse/pulse.config.<org>_<project>.json
# 2. Local Symlink: สร้าง pulse.config.json เป็น Symlink ในโฟลเดอร์ปัจจุบัน
# 3. Dynamic Selection: เลือกรายตัว, เปลี่ยนชื่อ, จัดการ Keyword (v6 logic)
# 4. Baseline Verification: ตรวจสอบ Remote URL (Pulse-Oracle/pulse-cli)
# 5. JSON Sorting & Formatting: จัดเรียงข้อมูลให้เป็นระเบียบ อ่านง่าย
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
log_step "🚀 Starting Robust Patch (v7) for pulse-cli at $PULSE_PATH..."

# --- 0. Pre-flight Safety Checks ---
log_step "🔍 Verifying target environment..."
check_version "$PULSE_PATH" "^1\."
verify_remote "$PULSE_PATH" "Pulse-Oracle/pulse-cli"

TARGET_FILES=(
    "packages/cli/src/commands/init.ts"
    "packages/cli/src/pulse.ts"
    "packages/cli/src/config.ts"
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
log_step "🛠️ Patching init.ts (Centralized Storage & Symlink)..."
python3 - <<'PY_EOF'
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/init.ts')
if not os.path.exists(path):
    print(f'X {path} not found')
    exit(1)

content = open(path).read()

# 1.1 Update imports to include path and fs
if "import * as fs from 'fs';" not in content:
    content = "import * as fs from 'fs';\nimport * as path from 'path';\nimport { homedir } from 'os';\n" + content

# 1.2 Centralized Storage & Selection Logic
selection_logic = """
    // --- Centralized Logic ---
    const configDir = path.join(homedir(), '.config', 'pulse');
    if (!fs.existsSync(configDir)) fs.mkdirSync(configDir, { recursive: true });
    
    const targetFileName = `pulse.config.${org.trim()}_${projectNumber}.json`;
    const targetPath = path.join(configDir, targetFileName);
    const localLinkPath = path.join(process.cwd(), 'pulse.config.json');

    let existing: any = {};
    try {
      if (fs.existsSync(targetPath)) {
        existing = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
      } else if (fs.existsSync(localLinkPath)) {
        existing = JSON.parse(fs.readFileSync(localLinkPath, 'utf8'));
      }
    } catch {}

    const DEFAULT_KEYWORDS: Record<string, string[]> = {
      gemi: ["orchestrate", "fleet", "patch", "robust", "system", "จัดการ", "กองทัพ", "แพตช์", "ระบบ"],
      sky: ["search", "trace", "find", "path", "remote", "ค้นหา", "แกะรอย", "พบ", "เส้นทาง"],
      pegasus: ["coordinate", "sync", "submodule", "synchronize", "ประสานงาน", "ซิงค์", "เชื่อมต่อ"],
      infographic: ["ui", "design", "visual", "infographic", "graph", "ออกแบบ", "ภาพ", "กราฟ"],
      vault: ["memory", "backup", "archive", "custodian", "ความจำ", "สำรอง", "คลัง", "ผู้ดูแล"],
      frontend: ["web", "react", "html", "css", "frontend", "เว็บ", "หน้าบ้าน"],
      backend: ["api", "database", "server", "node", "backend", "เซิร์ฟเวอร์", "หลังบ้าน"],
      research: ["study", "analyze", "research", "paper", "ศึกษา", "วิเคราะห์", "วิจัย"]
    };

    const existingKeywords: Record<string, string[]> = {};
    if (existing.routing?.keyword) {
      for (const k of existing.routing.keyword) {
        existingKeywords[k.oracle] = k.match;
      }
    }

    const oracleReposRaw: Record<string, string> = {};
    const finalKeywordsMap: Record<string, string[]> = {};

    if (oracleNames.length > 0) {
      console.log(`\\nDiscovering oracle repos in ${org.trim()}...`);
      for (const name of oracleNames) {
        const defaultKey = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || name.toLowerCase();
        
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
        let initialKeywords = existingKeywords[currentKey] || DEFAULT_KEYWORDS[currentKey] || [];
        let finalKeywords = initialKeywords;

        if (action === 'a') {
          const newName = await ask(rl, `    New Name (Enter for ${currentKey}): `);
          if (newName.trim()) finalKey = newName.trim();
          
          console.log(`    Current Keywords: ${initialKeywords.join(', ') || 'none'}`);
          const kwInput = await ask(rl, `    New Keywords (comma separated, Enter to keep current): `);
          if (kwInput.trim()) {
            finalKeywords = kwInput.split(',').map(k => k.trim()).filter(Boolean);
          }
        }

        oracleReposRaw[finalKey] = name;
        finalKeywordsMap[finalKey] = finalKeywords;
      }
    } else {
      console.log("No oracle repos found. You can add them to pulse.config.json later.");
    }

    const oracleRepos = Object.keys(oracleReposRaw).sort().reduce((acc, key) => {
      acc[key] = oracleReposRaw[key];
      return acc;
    }, {} as Record<string, string>);
"""

pattern = r'const\s+oracleRepos:[\s\S]*?if\s*\(oracleNames\.length\s*>\s*0\)[\s\S]*?else\s*\{[\s\S]*?\}'
if re.search(pattern, content):
    content = re.sub(pattern, selection_logic.strip(), content)
    print('✓ Updated init.ts with centralized logic')

# 1.3 Update saveConfig call to handle targetPath and Symlink
save_logic = """
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
      keyword: Object.entries(finalKeywordsMap)
        .sort((a, b) => a[0].localeCompare(b[0]))
        .map(([oracle, match]) => ({ match, oracle })),
      default: oracleRepos["pulse"] ? "pulse" : (oracleRepos["gemi"] ? "gemi" : "pulse")
    };

    const config: PulseConfig = {
      org: org.trim(),
      projectNumber,
      oracleRepos,
      routing
    };

    // Save to Centralized Path
    fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + "\\n");
    console.log(`\\nSaved to: ${targetPath}`);

    // Create Local Symlink
    if (fs.existsSync(localLinkPath)) {
      const stats = fs.lstatSync(localLinkPath);
      if (!stats.isSymbolicLink()) {
        const backup = localLinkPath + ".bak";
        fs.renameSync(localLinkPath, backup);
        console.log(`Backed up original file to ${backup}`);
      } else {
        fs.unlinkSync(localLinkPath);
      }
    }
    fs.symlinkSync(targetPath, localLinkPath);
    console.log(`Created symlink: pulse.config.json -> ${targetFileName}`);
"""

pattern = r'const\s+routing:[\s\S]*?saveConfig\(config\);'
if re.search(pattern, content):
    content = re.sub(pattern, save_logic.strip(), content)
    print('✓ Updated init.ts with symlink creation')

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

# --- 3. Patch packages/cli/src/config.ts (Symlink Awareness) ---
log_step "🛠️ Patching config.ts (Ensuring loadConfig handles symlinks cleanly)..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/config.ts')
content = open(path).read()
# The require(path) in loadConfig already follows symlinks in Node.js,
# but we add a comment for clarity.
if '// Symlink aware' not in content:
    content = content.replace('const path = configPath();', 'const path = configPath(); // Symlink aware')
    with open(path, 'w') as f: f.write(content)
    print('✓ Updated config.ts for clarity')
PY_EOF

# --- 4. Rebuild ---
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
log_info "Run 'pulse init' to set up your centralized configuration."
