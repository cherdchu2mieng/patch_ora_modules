// @pulse-patch: board_v2@v8.2.2
import { fmtBoardDates, filterItems, getItems, padDisplay, sliceDisplay } from "@pulse-oracle/sdk";
import { getContext } from "../config";

export async function board(filter?: string) {
  const allItems = await getItems(getContext());
  const indexed = allItems.map((item, i) => ({ item, rawIndex: i + 1 }));

  let filtered = filter
    ? indexed.filter(({ item }) => {
        const f = filter.toLowerCase();
        return (
          item.title.toLowerCase().includes(f) ||
          (item.oracle || "").toLowerCase().includes(f) ||
          (item.client || "").toLowerCase().includes(f) ||
          (item.priority || "").toLowerCase().includes(f) ||
          (item.status || "").toLowerCase().includes(f)
        );
      })
    : indexed;

  const groups = [
    filtered.filter(({ item }) => item.priority === "P0"),
    filtered.filter(({ item }) => item.priority === "P1"),
    filtered.filter(({ item }) => item.priority === "P2"),
    filtered.filter(({ item }) => !item.priority || item.priority === "-"),
  ];

  const label = filter ? `Master Board — ${filter}` : "Master Board";
  console.log(`\n  Pulse — ${label}  (${filtered.length} items)\n`);

  function shortRepo(repo: string): string {
    return repo.replace(/-oracle$/i, "");
  }

  function getStatusColor(status: string): string {
    const s = (status || "").toLowerCase();
    if (s === "done") return "\x1b[32m"; // Green
    if (s === "in progress") return "\x1b[34m"; // Blue
    if (s === "todo") return "\x1b[33m"; // Yellow
    if (s === "paused") return "\x1b[35m"; // Magenta
    return "";
  }

  function getPriorityColor(pri: string): string {
    const p = (pri || "").toUpperCase();
    if (p === "P0") return "\x1b[31m"; // Red
    if (p === "P1") return "\x1b[33m"; // Yellow/Orange
    if (p === "P2") return "\x1b[36m"; // Cyan
    return "";
  }

  const reset = "\x1b[0m";
  const cols = process.stdout.columns || 132;
  const titleWidth = Math.max(20, cols - 85);

  console.log(
    `  #  ${"Title".padEnd(titleWidth)}  Pri  Client    Oracle   Repo           WT          Status       Dates`
  );
  console.log("  " + "─".repeat(Math.min(cols - 4, 132)));

  for (const group of groups) {
    for (const { item, rawIndex } of group) {
      const title = padDisplay(sliceDisplay(item.title, titleWidth), titleWidth);
      const priColor = getPriorityColor(item.priority || "");
      const pri = `${priColor}${(item.priority || "-").padEnd(3)}${reset}`;
      
      const client = padDisplay(sliceDisplay(item.client || "-", 9), 9);
      const oracle = padDisplay(sliceDisplay(item.oracle || "-", 7), 7);
      const repo = padDisplay(sliceDisplay(shortRepo(item.repo || "-"), 13), 13);
      const wt = padDisplay(sliceDisplay(item.worktree || "-", 10), 10);
      
      const statusColor = getStatusColor(item.status || "");
      const status = `${statusColor}${(item.status || "-").padEnd(11)}${reset}`;
      
      const dates = fmtBoardDates(item["start date"] || "", item["target date"] || "");
      
      console.log(
        `  ${String(rawIndex).padStart(2)}  ${title}  ${pri}  ${client}  ${oracle}  ${repo}  ${wt}  ${status}  ${dates}`
      );
    }
  }
  console.log();
}
