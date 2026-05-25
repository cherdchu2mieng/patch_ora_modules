  // v8.4.0: Triage Authority Gate
  const cfg = (await import("../config")).loadConfig();
  const currentOracle = (await import("../config")).getCurrentOracle();
  if (currentOracle !== cfg.orchestrator) {
    console.log(`  ❌ Authorization Error: Only the designated Orchestrator (${cfg.orchestrator}) can perform board triage.`);
    return;
  }
