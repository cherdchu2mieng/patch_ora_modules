export async function init() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

  try {
    console.log("\n🛡️  Pulse Unified Protocol V1 (v8.5.3)");
    console.log("--------------------------------------");

    const localLinkPath = path.join(process.cwd(), "pulse.config.json");
    const user = await getGHUser();

    // --- Phase 1: Interactive Gathering ---
    const scopeInput = await ask(rl, "Initialize scope (ขอบเขตการทำงาน): [U]ser (ส่วนตัว) or [O]rg (องค์กร)? [U]: ");
    const isOrg = (scopeInput.trim().toLowerCase() || "u") === "o";

    const defaultITOrg = "itinfosv";
    const itOrg = (await ask(rl, `IT organization (องค์กร IT) [${defaultITOrg}]: `)).trim() || defaultITOrg;
    const itProjStr = (await ask(rl, `IT Master Board Project Number [1]: `)).trim() || "1";
    const itProj = parseInt(itProjStr);

    const githubUser = (await ask(rl, `user git hub name (ชื่อผู้ใช้งาน GitHub) [${user}]: `)).trim() || user;
    const aiProjStr = (await ask(rl, `AI Board Team Project Number [1]: `)).trim() || "1";
    const aiProj = parseInt(aiProjStr);

    const gOracle = (await ask(rl, "Gateway Oracle (ชื่อ Oracle ประตูทางเข้า - e.g. it49072): ")).trim();
    const orchestratorOracle = (await ask(rl, "Orchestrator Oracle (ชื่อ Oracle ผู้ประสานงาน - e.g. gemi): ")).trim();

    // --- Phase 2: Identity & Path Resolution ---
    const effectiveOrg = isOrg ? itOrg : githubUser;
    const projectNumber = isOrg ? itProj : aiProj;

    const configDir = path.join(homedir(), ".config", "pulse");
    if (!fs.existsSync(configDir)) fs.mkdirSync(configDir, { recursive: true });
    
    const targetFileName = `pulse.config.${effectiveOrg}_${projectNumber}.json`;
    const targetPath = path.join(configDir, targetFileName);

    let config: PulseConfig;

    // --- Phase 3: Config Generation ---
    const board = {
      ITB: { repo: `${itOrg}/pulse-oracle`, projectNumber: itProj },
      AIB: { repo: githubUser, projectNumber: aiProj }
    };

    let gateway: any;
    if (gOracle) {
      gateway = { repo: `${itOrg}/${gOracle}-oracle`, oracle: gOracle };
    }

    if (fs.existsSync(targetPath)) {
      console.log(`\n✅ Existing config found: ${targetFileName}`);
      config = JSON.parse(fs.readFileSync(targetPath, "utf8"));
      config.org = effectiveOrg;
      config.projectNumber = projectNumber;
      config.board = board;
      if (gateway) config.gateway = gateway;
      if (orchestratorOracle) {
        config.orchestrator = {
          repo: `${githubUser}/${config.oracleRepos[orchestratorOracle.toLowerCase()] || orchestratorOracle.toLowerCase() + "-oracle"}`,
          oracle: orchestratorOracle.toLowerCase()
        };
      }
    } else {
      console.log(`\n🔍 Discovering oracle repos in ${effectiveOrg}... `);
      const reposJson = await gh("repo", "list", effectiveOrg, "--json", "name", "--limit", "200");
      const repos: { name: string }[] = JSON.parse(reposJson);
      const oracleNames = repos.filter((r) => r.name.toLowerCase().includes("oracle")).map((r) => r.name);

      const oracleRepos: Record<string, string> = {};
      for (const name of oracleNames) {
        const key = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "") || name.toLowerCase();
        oracleRepos[key] = name;
      }
      console.log(`  ✅ Auto-added ${oracleNames.length} oracle repos.`);

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
        board,
        gateway,
        routing: buildRouting(oracleRepos),
        protocolVersion: "v1"
      };
    }

    // --- Phase 4: Save & Link ---
    fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + "\n");
    console.log(`\n💾 Saved Config: ${targetPath}`);

    if (fs.existsSync(localLinkPath)) {
      const stats = fs.lstatSync(localLinkPath);
      if (!stats.isSymbolicLink()) {
        fs.renameSync(localLinkPath, localLinkPath + ".bak");
      } else {
        fs.unlinkSync(localLinkPath);
      }
    }
    fs.symlinkSync(targetPath, localLinkPath);
    console.log(`🔗 Linked: pulse.config.json -> ${targetFileName}`);

    console.log("\n✅ Init complete. Use \"pulse kw sync\" to update keywords.");
  } catch (err: any) {
    console.error(`\n❌ Error during init: ${err.message}`);
  } finally {
    rl.close();
  }
}
