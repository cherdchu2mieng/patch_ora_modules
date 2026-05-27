  const blogRepo = cfg.blog?.repo || (typeof cfg.board === 'object' ? cfg.board.ITB : 'itinfosv/pulse-oracle');
  const [targetOrg, targetRepo] = blogRepo.includes("/") ? blogRepo.split("/") : [org, blogRepo];
