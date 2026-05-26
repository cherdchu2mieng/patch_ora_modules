import { saveConfig } from "../config";
import type { PulseConfig } from "../config";
import { gh } from "@pulse-oracle/sdk";
import * as readline from "readline";
import * as fs from 'fs';
import * as path from 'path';
import { homedir } from 'os';

// Helper for interaction
function ask(rl: readline.Interface, question: string): Promise<string> {
  return new Promise((resolve) => rl.question(question, resolve));
}

async function getGHUser(): Promise<string> {
  try {
    const userJson = await gh("api", "user", "--json", "login");
    return JSON.parse(userJson).login;
  } catch { return ""; }
}

export async function init() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

  try {
    // --- Phase 1: Context Discovery (Pre-Init) ---
    const localLinkPath = path.join(process.cwd(), 'pulse.config.json');
    let previousUserConfigPath: string | undefined;
    if (fs.existsSync(localLinkPath)) {
      try {
        previousUserConfigPath = fs.realpathSync(localLinkPath);
      } catch {}
    }

    // --- Phase 2: Selection & Identity ---
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
    if (isNaN(projectNumber)) {
      console.error("Project number must be a number.");
      return;
    }
    
    let orchestrator: string | undefined;
    let gateway: any;
    let syncTargetUser: string | undefined;

    // --- Phase 2.5: Gateway Configuration (Now for both User and Org) ---
    console.log("\n--- Gateway Configuration ---");
    const gRepo = (await ask(rl, "Gateway Repo (e.g. itinfosv/it49072-oracle, optional): ")).trim();
    if (gRepo) {
      const gOracle = (await ask(rl, "Gateway Oracle (e.g. pegasus): ")).trim();
      const gClient = (await ask(rl, "Gateway Client (e.g. IT Board Team): ")).trim();
      const gPriority = (await ask(rl, "Gateway Priority (e.g. P2): ")).trim();
      gateway = { repo: gRepo, oracle: gOracle, client: gClient, priority: gPriority };
      
      if (isOrg) {
        syncTargetUser = (await ask(rl, `Sync Gateway to User (default: ${user}): `)).trim() || user;
      }
    }

    // v8.4.0: Always ask for Orchestrator Oracle
    orchestrator = (await ask(rl, "Orchestrator Oracle (e.g. gemi): ")).trim() || undefined;

    // --- Phase 3: Repo Discovery ---
    console.log(`\nDiscovering oracle repos in ${effectiveOrg}... `);
    const reposJson = await gh("repo", "list", effectiveOrg, "--json", "name", "--limit", "200");
    const repos: { name: string }[] = JSON.parse(reposJson);
    const oracleNames = repos.filter((r) => r.name.toLowerCase().includes("oracle")).map((r) => r.name);

    const oracleRepos: Record<string, string> = {};
    if (isOrg) {
      for (const name of oracleNames) {
        const key = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || name.toLowerCase();
        oracleRepos[key] = name;
      }
      console.log(`  OK Auto-added ${oracleNames.length} oracle repos.`);
    } else {
      for (const name of oracleNames) {
        const defaultKey = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || name.toLowerCase();
        const confirm = await ask(rl, `Add oracle repo '${name}'? (Y/n) `);
        if (confirm.trim().toLowerCase() !== "n") {
          const keyInput = await ask(rl, `  Oracle name (default: ${defaultKey}): `);
          oracleRepos[keyInput.trim() || defaultKey] = name;
        }
      }
    }

    // --- Phase 4: Construct Standard Routing Object ---
    const toDisplay = (name: string) => name.charAt(0).toUpperCase() + name.slice(1).toLowerCase();
    
    const routing: any = {
      label: Object.keys(oracleRepos).sort().map(key => ({
        match: [`oracle/${key}`],
        oracle: toDisplay(key)
      })),
      repo: Object.entries(oracleRepos).reduce((acc: any, [key, repo]) => {
        acc[repo] = toDisplay(key);
        return acc;
      }, {}),
      keyword: [],
      default: oracleRepos["pulse"] ? "Pulse" : (oracleRepos["gemi" ] ? "Gemi" : undefined)
    };

    // --- Phase 5: Construct & Save Current Config ---
    const config: any = {
      org: effectiveOrg,
      projectNumber,
      oracleRepos,
      orchestrator: orchestrator,
      gateway: gateway,
      routing
    };

    const configDir = path.join(homedir(), '.config', 'pulse');
    if (!fs.existsSync(configDir)) fs.mkdirSync(configDir, { recursive: true });
    
    const targetFileName = `pulse.config.${effectiveOrg}_${projectNumber}.json`;
    const targetPath = path.join(configDir, targetFileName);

    fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + '\n');
    console.log(`\nSaved ${isOrg ? 'Org' : 'User'} Config: ${targetPath}`);

    // Update Symlink
    if (fs.existsSync(localLinkPath)) {
      const stats = fs.lstatSync(localLinkPath);
      if (!stats.isSymbolicLink()) {
        fs.renameSync(localLinkPath, localLinkPath + ".bak");
      } else {
        fs.unlinkSync(localLinkPath);
      }
    }
    fs.symlinkSync(targetPath, localLinkPath);
    console.log(`Linked: pulse.config.json -> ${targetFileName}`);

    // --- Phase 6: Targeted Gateway Sync (Org Mode Only) ---
    if (isOrg && gateway && syncTargetUser) {
      let userConfigPath: string | undefined;
      const explicitUserPath = path.join(configDir, `pulse.config.${syncTargetUser}_${projectNumber}.json`);

      if (fs.existsSync(explicitUserPath) && explicitUserPath !== targetPath) {
        userConfigPath = explicitUserPath;
      } else if (previousUserConfigPath && previousUserConfigPath !== targetPath && fs.existsSync(previousUserConfigPath)) {
        userConfigPath = previousUserConfigPath;
      }

      if (userConfigPath) {
        console.log(`\nSyncing Gateway to User Config: ${path.basename(userConfigPath)}`);
        const userCfg = JSON.parse(fs.readFileSync(userConfigPath, 'utf8'));
        userCfg.gateway = gateway;
        fs.writeFileSync(userConfigPath, JSON.stringify(userCfg, null, 2) + '\n');
        console.log(`OK Gateway synchronized successfully.`);
      }
    }

    console.log("\nInit complete. Use 'pulse kw sync' to update keywords.");
  } finally {
    rl.close();
  }
}
