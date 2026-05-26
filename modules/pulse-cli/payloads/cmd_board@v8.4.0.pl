import { fmtBoardDates, filterItems, getItems, padDisplay, sliceDisplay } from "@pulse-oracle/sdk";
import { getContext } from "../config";

export async function board(filter?: string) {
  try {
    // v8.4.0: Config Pre-check
    const configPath = require('path').join(process.cwd(), 'pulse.config.json');
    if (!require('fs').existsSync(configPath)) {
      console.log("  ❌ Error: Run pulse init first.");
      return;
    }

    const allItems = await getItems(getContext());
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

    const label = filter ? `Master Board — ${filter}` : "Master Board";
    console.log(`\n  Pulse — ${label}  (${filtered.length} items)\n`);

    function shortRepo(repo: string): string {
      return repo.replace(/-oracle$/i, "");
    }

    // v8.4.0: Added Anchor Column (10 Cols Total)
    console.log(
      "  #  Title                                          Pri  Client    Oracle   Repo           WT          Status       Anchor       Dates"
    );
    console.log("  " + "─".repeat(146));

    for (const group of groups) {
      for (const { item, rawIndex } of group) {
        const title = padDisplay(sliceDisplay(item.title, 45), 45);
        const pri = (item.priority || "-").padEnd(3);
        const client = padDisplay(sliceDisplay(item.client || "-", 9), 9);
        const oracle = padDisplay(sliceDisplay(item.oracle || "-", 7), 7);
        const repo = padDisplay(sliceDisplay(shortRepo(item.repo || "-"), 13), 13);
        const wt = padDisplay(sliceDisplay(item.worktree || "-", 10), 10);
        const status = (item.status || "-").padEnd(11);
        const anchor = padDisplay(sliceDisplay((item as any).anchor || "-", 11), 11);
        const dates = fmtBoardDates(item["start date"] || "", item["target date"] || "");
        console.log(
          `  ${String(rawIndex).padStart(2)}  ${title}  ${pri}  ${client}  ${oracle}  ${repo}  ${wt}  ${status}  ${anchor}  ${dates}`
        );
      }
    }
    console.log();
  } catch (e: any) {
    if (e.message?.includes("rate limit exceeded")) {
      console.error("❌ GitHub API Rate Limit Exceeded. Please wait a few minutes before trying again.");
    } else {
      console.error("❌ Failed to display board:", e.message);
    }
  }
}
