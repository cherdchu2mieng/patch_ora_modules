// @pulse-patch: cmd_keyword_v1@v8.5.0
import * as fs from "fs";
import * as path from "path";
import { getCurrentOracle } from "../config";

export async function keyword(args: string[]) {
  const sub = args[0];
  if (sub !== "sync") {
    console.log("Usage: pulse keyword sync");
    return;
  }

  console.log("\n  🌊 Pulse CLI Unified Protocol V1 (v8.5.0)");
  console.log("  🔍 Keyword Synchronization Mode\n");

  const localConfigPath = path.join(process.cwd(), "pulse.config.json");
  if (!fs.existsSync(localConfigPath)) {
    console.error("❌ Error: pulse.config.json not found. Run \"pulse init\" first.");
    return;
  }

  const targetPath = fs.realpathSync(localConfigPath);
  const config = JSON.parse(fs.readFileSync(targetPath, "utf8"));

  // 1. Identity Detection
  const oracleKey = getCurrentOracle();
  if (!oracleKey) {
    console.error("❌ Error: Current directory or environment not mapped to any Oracle.");
    return;
  }

  const toDisplay = (name: string) => name.charAt(0).toUpperCase() + name.slice(1).toLowerCase();
  const oracleDisplayName = toDisplay(oracleKey);

  // 2. Keyword Extraction from CLAUDE.md
  const claudePath = path.join(process.cwd(), "CLAUDE.md");
  if (!fs.existsSync(claudePath)) {
    console.error("❌ Error: CLAUDE.md not found in current directory.");
    return;
  }

  const docContent = fs.readFileSync(claudePath, "utf8");
  let keywords: string[] = [];

  const kwMatch = docContent.match(/\*\*Keywords\*\*:\s*([\s\S]+?)(?=\n(?:\*\*|#)|$)/i) || 
                  docContent.match(/Keywords:\s*([\s\S]+?)(?=\n(?:\*\*|#)|$)/i);
  
  if (kwMatch) {
    const lines = kwMatch[1].split("\n");
    for (const line of lines) {
      const cleanLine = line
        .replace(/^\s*[*-]\s*/, "")      
        .replace(/^\*\*[^*]+\*\*:\s*/, "") 
        .trim();
      
      if (cleanLine) {
        keywords.push(...cleanLine.split(",").map(w => w.trim()).filter(Boolean));
      }
    }
  }

  if (keywords.length === 0) {
    console.log("⚠️ No keywords found in CLAUDE.md. Please add a \"**Keywords**:\" section.");
    return;
  }

  if (!config.routing) config.routing = {};
  if (!config.routing.keyword) config.routing.keyword = [];

  const existingIdx = config.routing.keyword.findIndex((k: any) => k.oracle === oracleDisplayName);
  if (existingIdx !== -1) {
    config.routing.keyword[existingIdx].match = keywords;
  } else {
    config.routing.keyword.push({ match: keywords, oracle: oracleDisplayName });
  }

  config.routing.keyword.sort((a: any, b: any) => a.oracle.localeCompare(b.oracle));

  fs.writeFileSync(targetPath, JSON.stringify(config, null, 2) + "\n");
  
  console.log(`✅ Synchronized ${keywords.length} keywords for ${oracleDisplayName}.`);
  console.log(`   (ไทย: ${keywords.filter(k => /[ก-ฮ]/.test(k)).length} | English: ${keywords.filter(k => !/[ก-ฮ]/.test(k)).length})`);
  console.log("\n💡 Keywords are now active for routing and filtering.");
}