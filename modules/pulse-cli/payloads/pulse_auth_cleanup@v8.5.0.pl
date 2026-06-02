import { getContext, loadConfig, enforceAuth } from "./config";
import { board, timeline, add, set, fieldAdd, clearDate, scan, autoAssign, init, escalate, heartbeat, resume, remove, close, triage, scheduler, sentry, backfillWt, start, blog, cleanup } from "./commands/index";

const [cmd, ...args] = process.argv.slice(2);