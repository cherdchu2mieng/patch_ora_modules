#!/usr/bin/env bun
// @pulse-patch: pulse_v1_complete@v8.5.0
/**
 * pulse — GH Projects Master Board CLI
 * Pulse Oracle
 */

import { getContext, loadConfig, enforceAuth } from "./config";
import { 
  board, timeline, add, set, fieldAdd, clearDate, scan, 
  autoAssign, init, escalate, heartbeat, resume, remove, 
  close, triage, scheduler, sentry, backfillWt, start, 
  blog, cleanup, keyword, chb 
} from "./commands/index";

const [cmd, ...args] = process.argv.slice(2);

function parseFlag(flag: string): string | undefined {
  const idx = args.indexOf(flag);
  return idx !== -1 ? args[idx + 1] : undefined;
}

switch (cmd) {
  case "board":
  case "b":
    await board(args[0]);
    break;
  case "timeline":
  case "t":
    await timeline(args[0]);
    break;
  case "add":
  case "a": {
    const title = args[0];
    if (!title) {
      console.error("Usage: pulse add <title> [body] [--priority <P0-P3>] [--type <task|bug|feature>]");
      process.exit(1);
    }
    const positionalBody = args[1] && !args[1].startsWith("-") ? args[1] : undefined;
    
    await add(title, {
      body: positionalBody || parseFlag("--body"),
      type: parseFlag("--type"),
      priority: parseFlag("--priority"),
    });
    break;
  }
  case "set":
  case "s":
    if (!args[0] || !args[1]) {
      console.error("Usage: pulse set <item#> <value> [value2...]");
      process.exit(1);
    }
    await set(args[0], ...args.slice(1));
    break;
  case "field-add":
  case "fa":
    if (!args[0] || !args[1]) {
      console.error("Usage: pulse field-add <field> <option>");
      process.exit(1);
    }
    await fieldAdd(args[0], args[1]);
    break;
  case "clear":
  case "c":
    if (!args[0]) {
      console.error("Usage: pulse clear <item#> [start|target|both]");
      process.exit(1);
    }
    await clearDate(parseInt(args[0]), (args[1] as "start" | "target" | "both") || "both");
    break;
  case "scan":
    if (args.includes("--auto")) {
      await autoAssign({
        dryRun: args.includes("--dry-run"),
        notify: args.includes("--notify"),
      });
    } else if (args.includes("--mine")) {
      await scan({ mine: true, noCache: args.includes("--no-cache") });
    } else {
      await scan();
    }
    break;
  case "auto-assign":
  case "aa":
    await autoAssign({ dryRun: args.includes("--dry-run") || args.includes("--dry"), notify: args.includes("--notify") });
    break;
  case "init":
    await init();
    break;
  case "escalate":
  case "e": {
    if (!args[0]) {
      console.error("Usage: pulse escalate <title> [--oracle <name>] [--context <text>]");
      process.exit(1);
    }
    await escalate(args[0], {
      oracle: parseFlag("--oracle"),
      context: parseFlag("--context"),
    });
    break;
  }
  case "heartbeat":
  case "hb":
    await heartbeat({ fix: args.includes("--fix") });
    break;
  case "resume": {
    if (!args[0]) {
      console.error("Usage: pulse resume <item#>");
      process.exit(1);
    }
    await resume(parseInt(args[0]));
    break;
  }
  case "remove":
  case "rm": {
    if (!args[0]) {
      console.error("Usage: pulse remove <item#>");
      process.exit(1);
    }
    await remove(parseInt(args[0]));
    break;
  }
  case "close":
  case "done": {
    if (!args[0]) {
      console.error("Usage: pulse close <ID> [--force]");
      process.exit(1);
    }
    await close(args[0], {
      force: args.includes("--force"),
    });
    break;
  }
  case "keyword":
  case "kw":
    await keyword(args);
    break;
  case "task":
    await task(parseInt(args[0]));
    break;
  case "triage":
  case "tr":
    await triage();
    break;
  case "scheduler":
  case "sched":
    await scheduler({
      post: args.includes("--post"),
      days: parseInt(parseFlag("--days") || "1"),
    });
    break;
  case "sentry":
  case "monitor":
    await sentry({ post: args.includes("--post") });
    break;
  case "backfill-wt":
  case "bwt":
    await backfillWt({ dry: args.includes("--dry") });
    break;
  case "blog": {
    enforceAuth();
    if (!args[0]) {
      console.error("Usage: pulse blog <file.md> [patchWorkspaceUrl] [--title <title>] [--category <category>]");
      process.exit(1);
    }
    const wsUrl = args[1] && !args[1].startsWith("-") ? args[1] : undefined;
    await blog(args[0], {
      title: parseFlag("--title"),
      category: parseFlag("--category"),
      patchWorkspace: wsUrl
    });
    break;
  }
  case "start":
  case "go": {
    if (!args[0]) {
      console.error("Usage: pulse start <ID> [--force]");
      process.exit(1);
    }
    await start(args[0], {
      force: args.includes("--force"),
    });
    break;
  }
  case "chb":
    await chb(args[0], {
      delegated: args.includes("--Delegated"),
      returned: args.includes("--Returned"),
    });
    break;
  case "cleanup":
  case "gc":
    await cleanup({ dry: args.includes("--dry") });
    break;
  default:
    console.log(`
  🌊 Pulse CLI Unified Protocol V1 (v8.5.0)
  -----------------------------------------
  Usage: pulse <command> [args]

  Commands:
    board, b [filter]     View the master board (IT Master Board / AI Board Team)
    timeline, t [filter]  View task timeline
    add, a <title>        Create Issue + add to board
    set, s <#> <values>   Set fields (auto-detect field from value)
    field-add, fa <f> <v> Add option to field (preserves existing values!)
    clear, c <#> [field]  Clear dates (start|target|both)
    scan                  Discover untracked issues across all repos
    auto-assign, aa       Route unassigned items to Oracles [--dry-run] [--notify]
    init                  Initialize pulse.config.json (org, project, repos)
    escalate, e <title>   P0 escalation — delegate to oracle
    heartbeat, hb         Check agent health (stale/dead detection)
    resume <#>            Resume paused agent from board item
    remove, rm <#>        Remove item from board
    close, done <#>       Set Done + close GH issue
    triage, tr            Show items missing Priority/Client/Oracle (Governance)
    keyword, kw sync      Synchronize Oracle keywords from CLAUDE.md
    scheduler, sched      Daily standup/wrapup/idle detection [--post]
    sentry, monitor       Activity monitor — quick or deep [--post]
    backfill-wt, bwt      Scan disk worktrees + match to board items [--dry]
    start, go <ID>        Activate task (Pull + Set In Progress) [--force]
    blog <file.md>        Publish markdown to Discussion (with provenance)
    chb <ID> [--Delegated | --Returned] Handover standard (Bidirectional Sync)
    cleanup, gc [--dry]   Remove stale/orphan worktrees

  Options for add:
    --oracle <name>       Auto-resolve repo + add oracle label
    --repo <owner/repo>   Target repo (overrides oracle mapping)
    --priority <P0-P3>    Set priority

  Examples:
    pulse board
    pulse kw sync
    pulse tr
    pulse add \"New task\" --oracle neo --priority P0
`);
}