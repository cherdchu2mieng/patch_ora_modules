/** Get the org directory: <ghqRoot>/github.com/<org> */
export function getOrgDir(): string {
  return join(getGhqRoot(), "github.com", loadConfig().org);
}

export function getCurrentOracle(): string | undefined {
  if (process.env.ORACLE_NAME) return process.env.ORACLE_NAME.toLowerCase();
  const currentFolder = require("path").basename(process.cwd()).toLowerCase();
  const repos = loadConfig().oracleRepos;
  for (const [oracle, repo] of Object.entries(repos)) {
    if (repo.toLowerCase() === currentFolder) return oracle.toLowerCase();
  }
  return undefined;
}

export function enforceAuth() {
  const current = getCurrentOracle();
  const orchestrator = getContext().orchestrator;
  const orchName = (typeof orchestrator === "object" ? orchestrator.oracle : orchestrator) || "gemi";
  if (!current || current !== orchName.toLowerCase()) {
    console.error(`❌ Authority Error: Only Orchestrator "${orchName}" can perform this action.`);
    process.exit(1);
  }
}