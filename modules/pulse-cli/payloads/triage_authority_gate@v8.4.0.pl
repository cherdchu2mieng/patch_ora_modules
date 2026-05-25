  // v8.4.0: Triage Authority Gate
  const ctx = getContext();
  const currentOracle = (await import("../config")).getCurrentOracle();
  if (currentOracle !== ctx.orchestrator) {
    console.log(`  ❌ Authorization Error: Only the designated Orchestrator (${ctx.orchestrator}) can perform board triage.`);
    return;
  }
