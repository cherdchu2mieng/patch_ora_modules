/** Enforce that only the Orchestrator can run certain commands */
export function enforceAuth() {
  const current = getCurrentOracle();
  const orchestrator = getContext().orchestrator;
  if (orchestrator && current !== orchestrator) {
    console.error(`Only the designated Orchestrator '${orchestrator}' can perform board management (Current: ${current || 'unknown'}).`);
    process.exit(1);
  }
}
