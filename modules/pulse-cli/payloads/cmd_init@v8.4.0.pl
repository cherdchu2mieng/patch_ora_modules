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

function buildRouting(oracleRepos: Record<string, string>) {
  const toDisplay = (name: string) => name.charAt(0).toUpperCase() + name.slice(1).toLowerCase();
  return {
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
}

export async function init() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

  try {
    // --- Phase 1: Context Discovery ---
    const localLinkPath = path.join(process.cwd(), 'pulse.config.json');
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

    // --- Phase 3: Identity & Path Resolution ---
    const effectiveOrg = isOrg ? githubOrg : githubUser;
    const configDir = path.join(homedir(), '.config', 'pulse');
    if (!fs.existsSync(configDir)) fs.mkdirSync(configDir, { recursive: true });
    
    const targetFileName = `pulse.config.${effectiveOrg}_${projectNumber}.json`;
    const targetPath = path.join(configDir, targetFileName);

    let config: PulseConfig;

    if (fs.existsSync(targetPath)) {
      // --- Phase 4: Existing Config Patching ---
      console.log(`\nOK Existing config found: ${targetFileName}`);
      config = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
      
      const currentRepo = path.basename(process.cwd());
      const isMapped = Object.values(config.oracleRepos).some(r => r.toLowerCase() === currentRepo.toLowerCase());

      if (!isMapped) {
        const defaultKey = currentRepo.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || currentRepo.toLowerCase();
        const confirm = await ask(rl, `\nRepo '${currentRepo}' not in fleet. Add as oracle '${defaultKey}'? (Y/n) `);
        if (confirm.trim().toLowerCase() !== "n") {
           config.oracleRepos[defaultKey] = currentRepo;
           config.routing = buildRouting(config.oracleRepos);
           console.log("  OK Added current repo to fleet.");
        }
      }

      if (gateway) config.gateway = gateway;
      if (orchestratorOracle) {
         const orchRepoName = config.oracleRepos[orchestratorOracle.toLowerCase()] || `${orchestratorOracle.toLowerCase()}-oracle`;
         config.orchestrator = {
           repo: `${githubUser}/${orchRepoName}`,
           oracle: orchestratorOracle.toLowerCase()
         };
      }
      // Update Board mapping in existing config
      config.board = {
        ITB: `${githubOrg}/pulse-oracle`,
        AIB: `${githubUser}/pulse-oracle`
      };

    } else {
      // --- Phase 5: Full Discovery (New Config) ---
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

      let orchestrator: any;
      if (orchestratorOracle) {
        const orchRepoName = oracleRepos[orchestratorOracle.toLowerCase()] || `${orchestratorOracle.toLowerCase()}-oracle`;
        orchestrator = {
          repo: `${githubUser}/${orchRepoName}`,
          oracle: orchestratorOracle.toLowerCase()
        };
      }

      config = {
        org: effectiveOrg,
        projectNumber,
        oracleRepos,
        orchestrator,
        board: {
          ITB: `${githubOrg}/pulse-oracle`,
          AIB: `${githubUser}/pulse-oracle`
        },
        gateway,
        routing: buildRouting(oracleRepos)
      };
    }

    // --- Phase 6: Save & Link ---
    fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + '\n');
    console.log(`\nSaved Config: ${targetPath}`);

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
