/** Determine current oracle name based on env or current directory */
export function getCurrentOracle(): string | undefined {
  if (process.env.ORACLE_NAME) return process.env.ORACLE_NAME.toLowerCase();

  const currentFolder = require('path').basename(process.cwd()).toLowerCase();
  const repos = loadConfig().oracleRepos;
  for (const [oracle, repo] of Object.entries(repos)) {
    if (repo.toLowerCase() === currentFolder) return oracle.toLowerCase();
  }
  return undefined;
}
