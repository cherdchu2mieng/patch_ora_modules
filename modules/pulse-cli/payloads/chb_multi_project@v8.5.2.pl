  const { ctx: itbCtx, repo: itbFull } = resolveBoardContext("ITB");
  const { ctx: aibCtx, repo: aibFull } = resolveBoardContext("AIB");
  
  const isITB = ctx.org.toLowerCase() === itbCtx.org.toLowerCase();
  const isAIB = ctx.org.toLowerCase() === aibCtx.org.toLowerCase();