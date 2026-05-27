function getCurrentOracle(): string | undefined {
  if (process.env.ORACLE_NAME) return process.env.ORACLE_NAME.toLowerCase();
  const currentFolder = require('path').basename(process.cwd()).toLowerCase();
  const repos = loadConfig().oracleRepos;
  for (const [oracle, repo] of Object.entries(repos)) {
    if (repo.toLowerCase() === currentFolder) return oracle.toLowerCase();
  }
  return undefined;
}

function enforceOrchestrator() {
  const current = getCurrentOracle();
  const orchestrator = getContext().orchestrator;
  const orchName = (typeof orchestrator === 'object' ? orchestrator.oracle : orchestrator) || 'gemi';
  if (current !== orchName.toLowerCase()) {
    console.error(`❌ Authority Error: Only Orchestrator '${orchName}' can broadcast to the team.`);
    process.exit(1);
  }
}

const [cmd, ...args] = process.argv.slice(2);
