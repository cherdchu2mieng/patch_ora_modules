    const defaultOrg = "itinfosv";
    let orgInput = await ask(rl, \`GitHub org or user [\${defaultOrg}]: \`);
    const org = orgInput.trim() || defaultOrg;

    const numStr = await ask(rl, "Project number: ");
    const projectNumber = parseInt(numStr.trim());
    if (isNaN(projectNumber)) {
      console.error("Project number must be a number.");
      return;
    }

    // V1 Protocol Verification
    console.log(\`\\n🛡️ Initializing Unified Protocol V1 for \${org}...\`);

    // Auto-discover oracle repos
    console.log(\`\\nDiscovering oracle repos in \${org}...\`);
    const reposJson = await gh("repo", "list", org, "--json", "name", "--limit", "200");
    const repos: { name: string }[] = JSON.parse(reposJson);
    const oracleNames = repos
      .filter((r) => r.name.toLowerCase().includes("oracle"))
      .map((r) => r.name);

    const oracleRepos: Record<string, string> = {};
    for (const name of oracleNames) {
      const key = name.toLowerCase().replace(/-oracle$/, "").replace(/oracle-?/, "");
      oracleRepos[key || name.toLowerCase()] = name;
    }

    if (oracleNames.length > 0) {
      console.log(\`\\nFound \${oracleNames.length} oracle repos:\`);
      for (const [key, repo] of Object.entries(oracleRepos)) {
        console.log(\`  \${key} => \${repo}\`);
      }
      const confirm = await ask(rl, "\\nUse these? (Y/n) ");
      if (confirm.trim().toLowerCase() === "n") {
        console.log("Aborted. Edit pulse.config.json manually.");
        return;
      }
    } else {
      console.log("No oracle repos found. You can add them to pulse.config.json later.");
    }

    const config: PulseConfig = {
      org: org,
      projectNumber,
      oracleRepos,
      protocolVersion: "v1",
    };
