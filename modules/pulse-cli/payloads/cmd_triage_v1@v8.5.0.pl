import { getItems } from "@pulse-oracle/sdk";
import { getContext, enforceAuth } from "../config";

export async function triage() {
  // 1. Orchestrator Gate
  enforceAuth();

  console.log("\n  🌊 Pulse CLI Unified Protocol V1 (v8.5.0)");
  console.log("  🛡️  Governance Mode: Orchestrator Verified\n");

  const items = await getItems(getContext());
  const now = new Date();

  const missing = items
    .map((item, i) => ({ item, rawIndex: i + 1 }))
    .filter(({ item }) => !item.priority || !item.client || !item.oracle);

  const stale = items
    .map((item, i) => ({ item, rawIndex: i + 1 }))
    .filter(({ item }) => {
       if ((item.status || "").toLowerCase() !== "in progress") return false;
       if (!item.updatedAt) return false;
       const lastUpdate = new Date(item.updatedAt);
       const diffDays = (now.getTime() - lastUpdate.getTime()) / (1000 * 3600 * 24);
       return diffDays > 7;
    });

  if (missing.length === 0 && stale.length === 0) {
    console.log("  ✅ Board is healthy. No issues found.");
    return;
  }

  if (missing.length > 0) {
    console.log(`  🚩 Missing Metadata: ${missing.length} items`);
    console.log("  #   Title                                     Pri  Client    Oracle");
    console.log("  " + "─".repeat(80));
    for (const { item, rawIndex } of missing) {
      const idx = String(rawIndex).padStart(2);
      const title = item.title.slice(0, 40).padEnd(40);
      const pri = (item.priority || "---").padEnd(5);
      const client = (item.client || "---").padEnd(10);
      const oracle = item.oracle || "---";
      console.log(`  ${idx}  ${title}  ${pri}${client}${oracle}`);
    }
    console.log();
  }

  if (stale.length > 0) {
    console.log(`  ⏳ Stale Tasks (> 7 days): ${stale.length} items`);
    console.log("  #   Title                                     Status       Last Update");
    console.log("  " + "─".repeat(80));
    for (const { item, rawIndex } of stale) {
      const idx = String(rawIndex).padStart(2);
      const title = item.title.slice(0, 40).padEnd(40);
      const status = (item.status || "---").padEnd(12);
      const lastUpdate = item.updatedAt ? item.updatedAt.split("T")[0] : "---";
      console.log(`  ${idx}  ${title}  ${status} ${lastUpdate}`);
    }
    console.log();
  }
  
  console.log("💡 Suggestion: Use \"pulse set <#> <field> <value>\" to fix issues.\n");
}