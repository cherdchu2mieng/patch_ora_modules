// @pulse-patch: cmd_board_v1@v8.5.0
import { fmtBoardDates, filterItems, getItems, padDisplay, sliceDisplay } from "@pulse-oracle/sdk";
import { getContext, loadConfig } from "../config";

export async function board(filter?: string) {
  const ctx = getContext();
  const cfg = loadConfig();
  const allItems = await getItems(ctx);
  const indexed = allItems.map((item, i) => ({ item, rawIndex: i + 1 }));

  let filtered = filter
    ? indexed.filter(({ item }) => filterItems([item], filter).length > 0)
    : indexed;

  const groups = [
    filtered.filter(({ item }) => item.priority === "P0"),
    filtered.filter(({ item }) => item.priority === "P1"),
    filtered.filter(({ item }) => item.priority === "P2"),
    filtered.filter(({ item }) => !item.priority),
  ];

  const isITB = cfg.org.toLowerCase() === "itinfosv";
  const boardTitle = isITB ? "IT Master Board" : "AI Board Team";

  console.log("\n  🌊 Pulse CLI Unified Protocol V1 (v8.5.0)");
  const label = filter ? `${boardTitle} — ${filter}` : boardTitle;
  console.log(`  ${label}  (${filtered.length} items)\n`);

  function shortRepo(repo: string): string {
    return repo.replace(/-oracle$/i, "");
  }

  function getStatusColor(status: string): string {
    const s = (status || "").toLowerCase();
    if (s.includes("done") || s.includes("closed")) return "\x1b[32m"; // green
    if (s.includes("in progress")) return "\x1b[36m"; // cyan
    if (s.includes("paused")) return "\x1b[33m"; // yellow
    return "\x1b[37m"; // white
  }

  function getPriorityColor(pri: string): string {
    if (pri === "P0") return "\x1b[91m"; // red
    if (pri === "P1") return "\x1b[93m"; // yellow
    if (pri === "P2") return "\x1b[34m"; // blue
    return "\x1b[90m"; // gray
  }

  const reset = "\x1b[0m";

  // Columns: # (3), Title (40), Pri (4), Status (12), Oracle (8), Client (9), Start (6), Target (6), Anchor (12), Repo (12)
  console.log(
    "  #   Title                                     Pri  Status       Oracle   Client    Start   Target  Anchor      Repo"
  );
  console.log("  " + "─".repeat(125));

  for (const group of groups) {
    for (const { item, rawIndex } of group) {
      const idx = String(rawIndex).padStart(2);
      const title = padDisplay(sliceDisplay(item.title, 40), 40);
      const pri = (item.priority || "-").padEnd(3);
      const status = padDisplay(sliceDisplay(item.status || "-", 11), 11);
      const oracle = padDisplay(sliceDisplay(item.oracle || "-", 7), 7);
      const client = padDisplay(sliceDisplay(item.client || "-", 8), 8);
      const start = (item["start date"] ? item["start date"].slice(5) : "-").padEnd(6);
      const target = (item["target date"] ? item["target date"].slice(5) : "-").padEnd(6);
      const anchor = padDisplay(sliceDisplay(item.anchor || "-", 10), 10);
      const repo = padDisplay(sliceDisplay(shortRepo(item.repo || "-"), 12), 12);

      const pColor = getPriorityColor(item.priority);
      const sColor = getStatusColor(item.status);

      console.log(
        `  ${idx}  ${title}  ${pColor}${pri}${reset}  ${sColor}${status}${reset}  ${oracle}  ${client}  ${start}  ${target}  ${anchor}  ${repo}`
      );
    }
  }

  const stats = {
    total: filtered.length,
    new: filtered.filter(({ item }) => (item.status || "").toLowerCase().includes("new")).length,
    inProgress: filtered.filter(({ item }) => (item.status || "").toLowerCase().includes("in progress")).length,
    done: filtered.filter(({ item }) => (item.status || "").toLowerCase().includes("done") || (item.status || "").toLowerCase().includes("closed")).length,
  };
  console.log(`\n  Total: ${stats.total} | New: ${stats.new} | In Progress: ${stats.inProgress} | Done: ${stats.done}\n`);
}