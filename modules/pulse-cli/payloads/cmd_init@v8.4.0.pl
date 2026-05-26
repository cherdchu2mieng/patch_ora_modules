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
    // --- Phase 1: Context Discovery ---
    const localLinkPath = path.join(process.cwd(), 'pulse.config.json');
    let previousUserConfigPath: string | undefined;
    if (fs.existsSync(localLinkPath)) {
      try {
        previousUserConfigPath = fs.realpathSync(localLinkPath);
      } catch {}
    }

    const user = await getGHUser();

    // --- Phase 2: Information Gathering ---
    const githubUser = (await ask(rl, `GitHub user (default: ${user}): `)).trim() || user;
    const githubOrg = (await ask(rl, "GitHub org (default: itinfosv): ")).trim() || "itinfosv";
    
    const gOracle = (await ask(rl, "Gateway Oracle (e.g. it49072): ")).trim();
    let gateway: any;
    if (gOracle) {
      const gRepo = `${githubOrg}/${gOracle}-oracle`;
      gateway = { repo: gRepo, oracle: gOracle };
    }

    const orchestratorOracle = (await ask(rl, "Orchestrator Oracle (e.g. gemi): ")).trim();

    const scopeInput = await ask(rl, "\nInitialize scope: [U]ser (default) or [O]rg? (u) ");
    const isOrg = (scopeInput.trim().toLowerCase() || 'u') === 'o';

    const numStr = await ask(rl, "Project number: ");
    const projectNumber = parseInt(numStr.trim());
    if (isNaN(projectNumber)) {
      console.error("Error: Project number must be a number.");
      return;
    }

    // --- Phase 3: Selection Mapping ---
    const effectiveOrg = isOrg ? githubOrg : githubUser;

    // --- Phase 4: Repo Discovery ---
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

    // --- Phase 4.5: Orchestrator Object Construction ---
    let orchestrator: any;
    if (orchestratorOracle) {
      // Determine repo name from discovery or use default pattern
      const orchRepoName = oracleRepos[orchestratorOracle.toLowerCase()] || `${orchestratorOracle.toLowerCase()}-oracle`;
      orchestrator = {
        repo: `${githubUser}/${orchRepoName}`,
        oracle: orchestratorOracle.toLowerCase()
      };
    }

    // --- Phase 5: Construct Standard Routing Object ---
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

    // --- Phase 6: Construct & Save Current Config ---
    const config: PulseConfig = {
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
    console.log(`\nSaved Config: ${targetPath}`);

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

    console.log("\nInit complete. Use 'pulse kw sync' to update keywords.");
  } finally {
    rl.close();
  }
}
