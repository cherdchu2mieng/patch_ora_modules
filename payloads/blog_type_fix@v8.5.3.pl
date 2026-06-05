  const cfg = loadConfig();
  const org = ctx.org;
  const blogRepo = cfg.blog?.repo || getBoardRepo("ITB");
  const [targetOrg, targetRepo] = blogRepo.includes("/") ? blogRepo.split("/") : [org, blogRepo];
