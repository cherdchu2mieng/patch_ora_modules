  const currentOracle = getCurrentOracle();
  const isOrchestrator = ctx.orchestrator && currentOracle === ctx.orchestrator;
  const oracleLower = opts.oracle?.toLowerCase();
  
  if (oracleLower && currentOracle === oracleLower) {
    if (!opts.priority) opts.priority = "P0";
    if (!opts.client) opts.client = "Self-Direct";
  }
  
  if (oracleLower && currentOracle !== oracleLower && !isOrchestrator) {
    console.log(`Note: Only oracle '${ctx.orchestrator || 'Orchestrator'}' can perform board assignment. Creating issue only.`);
    opts.oracle = undefined; 
  }
