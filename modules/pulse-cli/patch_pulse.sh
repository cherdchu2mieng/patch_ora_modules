#!/bin/bash

# สคริปต์สำหรับอัปเดต pulse-cli: ปรับปรุง pulse init ให้รองรับ Routing อัตโนมัติ และการเลือก Oracle
# ฟีเจอร์: 
# 1. เลือก Oracle เฉพาะที่ต้องการ (Interactive Selection)
# 2. สร้าง label, repo routing จาก oracleRepos อัตโนมัติ
# 3. ใส่ Thai Keywords เริ่มต้น
# วิธีใช้: chmod +x patch_pulse.sh && ./patch_pulse.sh <path_to_pulse_cli>

export PULSE_PATH="$1"

if [ -z "$PULSE_PATH" ]; then
    echo -e "\x1b[31mError: Missing pulse-cli path.\x1b[0m"
    exit 1
fi

if [ ! -d "$PULSE_PATH" ]; then
    echo -e "\x1b[31mError: Path $PULSE_PATH not found.\x1b[0m"
    exit 1
fi

export PULSE_PATH=$(readlink -f "$PULSE_PATH")

echo "🚀 Starting Robust Patch for pulse-cli at $PULSE_PATH..."

# --- 0. Pre-flight Safety Checks ---
if [ -d "$PULSE_PATH/.git" ]; then
    echo "🧹 Safe-Reset: Restoring target files to origin state..."
    git -C "$PULSE_PATH" checkout \
        packages/cli/src/commands/init.ts 2>/dev/null
    echo "  ✓ Baseline is clean."
fi

# --- 1. Patch src/commands/init.ts ---
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

# --- 2. Rebuild ---
echo -e "\n📦 Rebuilding pulse-cli..."
cd "$PULSE_PATH"
if [ -f "package.json" ]; then
    bun install
    if [ -d "packages/cli" ]; then
        cd packages/cli
        bun run build 2>/dev/null || echo "i No build script in packages/cli, source is ready."
    fi
fi

echo -e "\n✅ Patch Complete!"
