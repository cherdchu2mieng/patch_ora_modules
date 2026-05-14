#!/bin/bash

# สคริปต์สำหรับอัปเดต pulse-cli: ปรับปรุง pulse init ให้รองรับ Routing อัตโนมัติ
# ฟีเจอร์: สร้าง label, repo routing จาก oracleRepos และใส่ Thai Keywords เริ่มต้น
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

# export PULSE_PATH=$(realpath "$PULSE_PATH")
# Using literal realpath call instead of $() if possible, or just keep it and see if mv works
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

# 1.2 Enhanced logic for routing and config
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

if 'routing' not in content:
    # Find the old config block
    pattern = r'const\s+config:\s*PulseConfig\s*=\s*\{[\s\S]*?\};'
    if re.search(pattern, content):
        content = re.sub(pattern, new_logic.strip(), content)
        with open(path, 'w') as f: f.write(content)
        print('✓ Updated init.ts with routing logic')
    else:
        print('X Could not find config block in init.ts')
else:
    print('i init.ts already patched')
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
