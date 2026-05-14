#!/bin/bash

# สคริปต์สำหรับอัปเดต pulse-cli: เวอร์ชัน Org Scope & Gateway Sync (v7.5)
# ฟีเจอร์: 
# 1. Org Scope: รองรับการเลือก Init ระดับ User หรือ Org
# 2. Gateway Cross-Sync: หากรัน Init ใน Org ระบบจะซิงค์เฉพาะ Repo ปัจจุบันกลับไปที่ User Config หลักอัตโนมัติ
# 3. Lean Init: Discovery เฉพาะเมื่อยังไม่มีไฟล์ Config กลาง
# 4. Smart Symlink: สร้าง Symlink เฉพาะใน Repo ที่ลงท้ายด้วย -oracle
# 5. Decentralized Keywords: ดึง Identity จากไฟล์ CLAUDE.md มาสร้าง Routing อัตโนมัติ
# 6. Patched Indicator: เพิ่มเครื่องหมาย (patched 🌊 v7.5) ใน pulse --version

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
log_step "🚀 Starting Gateway Patch (v7.5) for pulse-cli at $PULSE_PATH..."

# --- 0. Pre-flight Safety Checks ---
log_step "🔍 Verifying target environment..."
check_version "$PULSE_PATH" "^1\."
verify_remote "$PULSE_PATH" "Pulse-Oracle/pulse-cli"

TARGET_FILES=(
    "packages/cli/src/commands/init.ts"
    "packages/cli/src/commands/index.ts"
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
log_step "🛠️ Patching init.ts (Scope & Cross-Sync)..."
python3 - <<'PY_EOF'
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/init.ts')
if not os.path.exists(path):
    print(f'X {path} not found')
    exit(1)

content = open(path).read()

# 1.1 Update imports
if "import * as fs from 'fs';" not in content:
    content = "import * as fs from 'fs';\nimport * as path from 'path';\nimport { homedir } from 'os';\n" + content

# 1.2 Helper for GH User
if "async function getGHUser()" not in content:
    helper = """
async function getGHUser(): Promise<string> {
  try {
    const { gh } = require("@pulse-oracle/sdk");
    const userJson = await gh("api", "user", "-q", ".login");
    return userJson.trim();
  } catch (e) {
    return "";
  }
}
"""
    content = content.replace('export async function init() {', helper + '\nexport async function init() {')

# 1.3 Implementation Plan Logic
init_code = r'''export async function init() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

  try {
    const scopeInput = await ask(rl, "Initialize scope: [U]ser (default) or [O]rg? (u) ");
    const isOrg = (scopeInput.trim().toLowerCase() || 'u') === 'o';
    const orgInput = await ask(rl, isOrg ? "GitHub org: " : "GitHub user (default: current): ");
    
    const user = await getGHUser();
    const effectiveOrg = orgInput.trim() || (isOrg ? "" : user);

    if (isOrg && !effectiveOrg) {
      console.error("Error: Organization name is required for Org scope.");
      return;
    }

    const numStr = await ask(rl, "Project number: ");
    const projectNumber = parseInt(numStr.trim());

    if (!effectiveOrg || isNaN(projectNumber)) {
      console.error("Invalid org or project number.");
      return;
    }

    const configDir = path.join(homedir(), '.config', 'pulse');
    if (!fs.existsSync(configDir)) fs.mkdirSync(configDir, { recursive: true });
    
    const targetFileName = `pulse.config.${effectiveOrg}_${projectNumber}.json`;
    const targetPath = path.join(configDir, targetFileName);
    const localLinkPath = path.join(process.cwd(), 'pulse.config.json');

    // --- Discovery Logic ---
    if (!fs.existsSync(targetPath)) {
      console.log(`\nNew Fleet detected. Performing discovery scan in ${effectiveOrg}...`);
      const reposJson = await gh("repo", "list", effectiveOrg, "--json", "name", "--limit", "200");
      const repos: { name: string }[] = JSON.parse(reposJson);
      const oracleNames = repos
        .filter((r) => r.name.toLowerCase().includes("oracle"))
        .map((r) => r.name);

      const oracleRepos: Record<string, string> = {};
      for (const name of oracleNames) {
        const defaultKey = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || name.toLowerCase();
        if (isOrg) {
          oracleRepos[defaultKey] = name;
        } else {
          const action = await ask(rl, `  Include ${defaultKey} (${name})? [y]es, [n]o? (y) `);
          if ((action.trim().toLowerCase() || 'y') === 'y') {
            oracleRepos[defaultKey] = name;
          }
        }
      }
      if (isOrg) console.log(`  Auto-included ${Object.keys(oracleRepos).length} oracles from Org.`);

      const config = {
        org: effectiveOrg,
        projectNumber,
        oracleRepos,
        routing: {
          label: Object.keys(oracleRepos).sort().map(o => ({ match: [`oracle/${o}`], oracle: o })),
          repo: Object.entries(oracleRepos).reduce((acc, [o, r]) => { acc[r] = o; return acc; }, {} as any),
          keyword: Object.keys(oracleRepos).map(o => ({ match: [], oracle: o })),
          default: "pulse"
        }
      };
      fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + '\n');
      console.log(`Created central config: ${targetPath}`);
    } else {
      console.log(`Found existing central config: ${targetPath}`);
    }

    // --- Oracle-only Symlinking & Cross-Sync ---
    const currentDir = path.basename(process.cwd());
    if (currentDir.toLowerCase().endsWith("-oracle")) {
      if (fs.existsSync(localLinkPath)) {
          const stats = fs.lstatSync(localLinkPath);
          if (stats.isSymbolicLink()) fs.unlinkSync(localLinkPath);
          else fs.renameSync(localLinkPath, localLinkPath + ".bak");
      }
      fs.symlinkSync(targetPath, localLinkPath);
      console.log(`\nSuccess: Created symlink for Oracle repo: ${currentDir}`);

      // --- Cross-Sync Gateway to User Config ---
      if (isOrg && user) {
        const userConfigPath = path.join(path.dirname(targetPath), `pulse.config.${user}_${projectNumber}.json`);
        if (fs.existsSync(userConfigPath)) {
          console.log(`\n📡 Syncing Gateway Repo to User Config (${user})...`);
          const userConfig = JSON.parse(fs.readFileSync(userConfigPath, 'utf8'));
          const oracleName = currentDir.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || currentDir.toLowerCase();
          
          userConfig.oracleRepos = userConfig.oracleRepos || {};
          userConfig.oracleRepos[oracleName] = currentDir;
          
          if (userConfig.routing && userConfig.routing.repo) {
            userConfig.routing.repo[currentDir] = oracleName;
          }
          
          fs.writeFileSync(userConfigPath, JSON.stringify(userConfig, null, 2) + '\n');
          console.log(`✓ Updated User Config: ${userConfigPath}`);
        }
      }
      console.log(`Run 'pulse keyword sync' next to update keywords.`);
    } else {
      console.log(`\nWarning: Current directory '${currentDir}' is not an Oracle repo. Skipping symlink.`);
    }
  } finally {
    rl.close();
  }
}'''

start_m = "export async function init() {"
end_m = "rl.close();\n  }\n}"
if start_m in content and end_m in content:
    head = content.split(start_m)[0]
    tail = content.split(end_m)[1]
    content = head + init_code + tail
    print("✓ Updated init.ts with Scope & Cross-Sync Logic")
else:
    print("X Failed to find init function markers")

with open(path, 'w') as f: f.write(content)
PY_EOF

# --- 2. Patch packages/cli/src/commands/index.ts ---
log_step "🛠️ Patching commands/index.ts (Export Keyword)..."
python3 - <<'PY_EOF'
import os
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/commands/index.ts')
content = open(path).read()
if 'export { keyword }' not in content:
    content += 'export { keyword } from "./keyword";\n'
    with open(path, 'w') as f: f.write(content)
    print('✓ Exported keyword command')
PY_EOF

# --- 3. Create packages/cli/src/commands/keyword.ts ---
log_step "🛠️ Creating commands/keyword.ts (Keywords from CLAUDE.md)..."
cat << 'K_EOF' > "$PULSE_PATH/packages/cli/src/commands/keyword.ts"
import * as fs from 'fs';
import * as path from 'path';

export async function keyword(args: string[]) {
  const sub = args[0];
  if (sub !== "sync") {
    console.log("Usage: pulse keyword sync (or pulse kw sync)");
    return;
  }

  const localConfigPath = path.join(process.cwd(), 'pulse.config.json');
  if (!fs.existsSync(localConfigPath)) {
    console.error("Error: No pulse.config.json found. Run 'pulse init' first.");
    return;
  }

  const targetPath = fs.realpathSync(localConfigPath);
  const config = JSON.parse(fs.readFileSync(targetPath, 'utf8'));

  const currentRepo = path.basename(process.cwd());
  const oracleName = config.routing?.repo?.[currentRepo];

  if (!oracleName) {
    console.error(`Error: Repo '${currentRepo}' is not mapped to an Oracle in pulse.config.json`);
    return;
  }

  console.log(`Syncing keywords for Oracle: ${oracleName} (from CLAUDE.md)...`);

  const claudePath = path.join(process.cwd(), 'CLAUDE.md');
  if (!fs.existsSync(claudePath)) {
    console.error(`Error: CLAUDE.md not found in ${process.cwd()}`);
    return;
  }

  const docContent = fs.readFileSync(claudePath, 'utf8');
  let keywords: string[] = [];
  
  const kwMatch = docContent.match(/\*\*Keywords\*\*:\s*([\s\S]+?)(?=\n\n|\n#|$)/);
  if (kwMatch) {
    const kwLines = kwMatch[1].split('\n');
    for (const line of kwLines) {
      const match = line.match(/^\s*-\s+(?:[^:]+:\s*)?(.+)$/);
      if (match) {
        const words = match[1].split(',').map(w => w.trim());
        keywords.push(...words);
      }
    }
  }

  if (keywords.length === 0) {
    console.warn(`Warning: No keywords found in CLAUDE.md. (Ensure they follow the **Keywords**: section)`);
    return;
  }

  console.log(`Found keywords: ${keywords.join(', ')}`);

  if (!config.routing) config.routing = {};
  if (!config.routing.keyword) config.routing.keyword = [];
  const existingIdx = config.routing.keyword.findIndex((k: any) => k.oracle === oracleName);
  
  if (existingIdx !== -1) {
    config.routing.keyword[existingIdx].match = keywords;
  } else {
    config.routing.keyword.push({ match: keywords, oracle: oracleName });
  }

  fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + '\n');
  console.log(`Successfully updated global config: ${targetPath}`);
}
K_EOF

# --- 4. Patch packages/cli/src/pulse.ts ---
log_step "🛠️ Patching pulse.ts (Version & Command Link)..."
python3 - <<'PY_EOF'
import os, re
path = os.path.join(os.environ['PULSE_PATH'], 'packages/cli/src/pulse.ts')
content = open(path).read()

# 4.1 Update Version Indicator
content = re.sub(r' \(patched 🌊 v7\.4\.[0-9]+\)', ' (patched 🌊 v7.5)', content)
if '(patched 🌊 v7.5)' not in content:
    content = content.replace('.version(packageJson.version)', f'.version(packageJson.version + " (patched 🌊 v7.5)")')

# 4.2 Add keyword/kw command
if 'command("keyword")' not in content:
    kw_code = """  program
    .command("keyword")
    .alias("kw")
    .description("Sync keywords from CLAUDE.md to central config")
    .argument("[args...]", "Command arguments")
    .action(async (args) => {
      const { keyword } = await import("./commands");
      await keyword(args);
    });"""
    content = content.replace('program.parse();', kw_code + '\n\n  program.parse();')

with open(path, 'w') as f: f.write(content)
print('✓ Updated pulse.ts with v7.5 version and keyword command')
PY_EOF

log_step "✅ Patch Preparation Complete (v7.5)!"
log_info "The pulse-cli source is patched. Rebuild may be required."
