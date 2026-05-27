// @pulse-patch: keyword_cmd@v8.2.1
import * as fs from 'fs';
import * as path from 'path';

export async function keyword(args: string[]) {
  const sub = args[0];
  if (sub !== "sync") {
    console.log("Usage: pulse keyword sync");
    return;
  }

  const localConfigPath = path.join(process.cwd(), 'pulse.config.json');
  if (!fs.existsSync(localConfigPath)) {
    console.error("Error: pulse.config.json not found.");
    return;
  }

  const targetPath = fs.realpathSync(localConfigPath);
  const config = JSON.parse(fs.readFileSync(targetPath, 'utf8'));

  // 1. Dynamic Identity Detection
  const currentRepo = path.basename(process.cwd());
  const oracleRepos = config.oracleRepos || {};
  let oracleKey: string | undefined;

  for (const [key, repo] of Object.entries(oracleRepos)) {
    if ((repo as string).toLowerCase() === currentRepo.toLowerCase()) {
      oracleKey = key;
      break;
    }
  }

  if (!oracleKey) oracleKey = process.env.ORACLE_NAME?.toLowerCase();
  if (!oracleKey) {
    console.error(`Error: Repo '${currentRepo}' not mapped to any Oracle.`);
    return;
  }

  const toDisplay = (name: string) => name.charAt(0).toUpperCase() + name.slice(1).toLowerCase();
  const oracleDisplayName = toDisplay(oracleKey);

  console.log(`\n🌊 Syncing keywords for Oracle: ${oracleDisplayName}...`);

  // 2. Keyword Extraction from CLAUDE.md
  const claudePath = path.join(process.cwd(), 'CLAUDE.md');
  if (!fs.existsSync(claudePath)) {
    console.error("Error: CLAUDE.md not found.");
    return;
  }

  const docContent = fs.readFileSync(claudePath, 'utf8');
  let keywords: string[] = [];

  const kwMatch = docContent.match(/\*\*Keywords\*\*:\s*([\s\S]+?)(?=\n(?:\*\*|#)|$)/);
  if (kwMatch) {
    const lines = kwMatch[1].split('\n');
    for (const line of lines) {
      const cleanLine = line
        .replace(/^\s*[*-]\s*/, '')      
        .replace(/^\*\*[^*]+\*\*:\s*/, '') 
        .trim();
      
      if (cleanLine) {
        keywords.push(...cleanLine.split(',').map(w => w.trim()).filter(Boolean));
      }
    }
  }

  if (keywords.length === 0) {
    console.log("⚠️ No keywords found.");
    return;
  }

  // 3. Update Standard Routing Object
  if (!config.routing) config.routing = {};
  if (!config.routing.keyword) config.routing.keyword = [];

  // Update 'keyword' array (Standard)
  const existingIdx = config.routing.keyword.findIndex((k: any) => k.oracle === oracleDisplayName);
  if (existingIdx !== -1) {
    config.routing.keyword[existingIdx].match = keywords;
  } else {
    config.routing.keyword.push({ match: keywords, oracle: oracleDisplayName });
  }

  // Sorting
  config.routing.keyword.sort((a: any, b: any) => a.oracle.localeCompare(b.oracle));

  // Clean up legacy 'keywords' object if present
  if (config.routing.keywords) delete config.routing.keywords;

  fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + '\n');
  console.log(`✓ Synchronized ${keywords.length} clean keywords for ${oracleDisplayName}.`);
}
