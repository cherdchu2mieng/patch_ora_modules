    const itbRepo = (await ask(rl, "IT Master Board Repo [itinfosv/pulse-oracle]: ")).trim() || "itinfosv/pulse-oracle";
    const itbProj = (await ask(rl, "IT Master Board Project Number [1]: ")).trim() || "1";
    
    const aibRepo = (await ask(rl, `AI Board Team Repo [${githubOrg}/pulse-oracle]: `)).trim() || `${githubOrg}/pulse-oracle`;
    const aibProj = (await ask(rl, `AI Board Team Project Number [${projectNumber}]: `)).trim() || String(projectNumber);

    config.board = {
      ITB: { repo: itbRepo, projectNumber: parseInt(itbProj) },
      AIB: { repo: aibRepo, projectNumber: parseInt(aibProj) }
    };