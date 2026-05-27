  const blogRepo = cfg.blog?.repo || (typeof cfg.board === "object" ? cfg.board.ITB : "itinfosv/pulse-oracle");
  const [targetOrg, targetRepo] = blogRepo.includes("/") ? blogRepo.split("/") : [org, blogRepo];
  const repo = getRepoName();
  
  // Robust Path Detection
  let repoPath = file.includes("ψ/writing/") 
    ? "ψ/writing/" + file.split("ψ/writing/")[1] 
    : file.replace(new RegExp(`.*${repo}/`), "");
    
  let sourceUrl = `https://github.com/${org}/${repo}/blob/main/${repoPath.replace(/ψ/g, "%CF%88")}`;

  const patchWs = cfg.patchWorkspace;
  if (patchWs && repoPath.startsWith("ψ/writing/")) {
    const mappedPath = repoPath.replace(/^ψ\/writing\//, "docs/requirements/");
    sourceUrl = `${patchWs.replace(/\/$/, "")}/blob/main/${mappedPath.replace(/ψ/g, "%CF%88")}`;
    console.log(`  Traceability: mapped to Patch Workspace 🛡️`);
  }
  const commitUrl = `https://github.com/${org}/${repo}/commit/${gitInfo.hash}`;

  const provenance = [
    "",
    "---",
    "**Provenance**",
    `- Session: \`${sessionId.slice(0, 8)}\``,
    `- Commit: [\`${gitInfo.hash}\`](${commitUrl}) — ${gitInfo.message}`,
    `- Author: ${gitInfo.author} (${gitInfo.date.slice(0, 10)})`,
    `- Source: [\`${repoPath}\`](${sourceUrl})`,
    `- Published: ${timestamp} ICT`,
    "",
    "<details><summary>Recent commits</summary>",
    "",
    ...recentCommits.map(c => {
      const [h, ...rest] = c.split(" ");
      return `- [\`${h}\`](https://github.com/${org}/${repo}/commit/${h}) ${rest.join(" ") }`;
    }),
    "",
    "</details>",
    "",
    "*— Oracle (Pulse)*",
  ].join("\\n");

  const fullBody = bodyContent + "\\n" + provenance;

  const category = opts.category || cfg.blog?.category || "Show and tell";
  console.log(`Publishing: "${title}" → ${targetOrg}/${targetRepo} [${category}]`);
  const discussion = await createDiscussion(targetOrg, targetRepo, title, fullBody, category);
