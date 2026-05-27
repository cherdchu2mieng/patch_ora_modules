import { getItems } from "@pulse-oracle/sdk";
import { getContext } from "../config";

export async function triage() {
  try {
    // v8.4.0: Config Pre-check
    const configPath = require('path').join(process.cwd(), 'pulse.config.json');
    if (!require('fs').existsSync(configPath)) {
      console.log("  ❌ Error: Run pulse init first.");
      return;
    }

    // v8.4.0: Triage Authority Gate
    const cfg = (await import("../config")).loadConfig();
    const currentOracle = (await import("../config")).getCurrentOracle();
    if (currentOracle !== cfg.orchestrator) {
      console.log(`  ❌ Authorization Error: Only the designated Orchestrator (${cfg.orchestrator}) can perform board triage.`);
      return;
    }

    const items = await getItems(getContext());

    const missing = items
      .map((item, i) => ({ item, rawIndex: i + 1 }))
      .filter(({ item }) => !item.priority || !item.client || !item.oracle);

    if (missing.length === 0) {
      console.log("  All items have Priority, Client, and Oracle set.");
      return;
    }

    console.log(`
  Pulse — Triage  (${missing.length} items need metadata)
`);
    console.log(
      "  #".padEnd(6) + "Title".padEnd(48) + "Pri".padEnd(5) + "Client".padEnd(11) + "Oracle"
    );
    console.log("  " + "─".repeat(80));

    for (const { item, rawIndex } of missing) {
      const title = item.title.slice(0, 45).padEnd(45);
      const pri = (item.priority || "---").padEnd(5);
      const client = (item.client || "---").padEnd(11);
      const oracle = item.oracle || "---";

      console.log(
        `  ${String(rawIndex).padStart(3)}  ${title}  ${pri}${client}${oracle}`
      );
    }
    console.log();
  } catch (e: any) {
    if (e.message?.includes("rate limit exceeded")) {
      console.error("❌ GitHub API Rate Limit Exceeded. Please wait a few minutes before trying again.");
    } else {
      console.error("❌ Failed to execute triage:", e.message);
    }
  }
}
