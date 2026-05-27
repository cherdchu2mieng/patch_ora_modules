  let repoPath = file.replace(new RegExp(`.*${repo}/`), "");
  let sourceUrl = `https://github.com/${org}/${repo}/blob/main/${repoPath.replace(/ψ/g, "%CF%88")}`;

  const patchWs = cfg.patchWorkspace;
  if (patchWs && repoPath.startsWith("ψ/writing/")) {
    const mappedPath = repoPath.replace(/^ψ\/writing\//, "docs/requirements/");
    sourceUrl = `${patchWs.replace(/\/$/, "")}/blob/main/${mappedPath.replace(/ψ/g, "%CF%88")}`;
    console.log(`  Traceability: mapped to Patch Workspace 🛡️`);
  }
