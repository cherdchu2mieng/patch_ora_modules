// @pulse-patch: blog_orchestrator@v8.4.2
import { readFileSync, writeFileSync, existsSync } from "fs";
import { basename } from "path";
import { createDiscussion } from "@pulse-oracle/sdk";
import type { BlogOpts } from "@pulse-oracle/sdk";
import { getContext, getRepoName, loadConfig, enforceAuth } from "../config";

export async function blog(file: string, opts: BlogOpts = {}) {
  // 1. File Existence Guard
  if (!existsSync(file)) {
    console.error(`❌ Error: File not found: ${file}`);
    console.log("Usage: pulse blog <file.md> [--title <title>] [--category <category>]");
    process.exit(1);
  }

  enforceAuth();
  const ctx = getContext();
  const content = readFileSync(file, "utf-8");

  const title = opts.title || content.match(/^##\s+(.+)$/m)?.[1] || basename(file, ".md");
  const bodyContent = content.replace(/^---[\s\S]*?---\n*/m, "").trim();

  const sessionId = process.env.CLAUDE_SESSION_ID || "unknown";
  const gitInfo = (() => {
    try {
      const fmt = "%h\t%s\t%an\t%aI";
      const result = Bun.spawnSync(["git", "log", "-1", `--format=${fmt}`], { stdout: "pipe" });
      const [hash, message, author, date] = new TextDecoder().decode(result.stdout).trim().split("\t");
      return { hash, message, author, date };
    } catch { return { hash: "unknown", message: "", author: "", date: "" }; }
  })();
  
  const recentCommits = (() => {
    try {
      const result = Bun.spawnSync(["git", "log", "--oneline", "-5", "--format=%h %s"], { stdout: "pipe" });
      return new TextDecoder().decode(result.stdout).trim().split("\n");
    } catch { return []; }
  })();
  
  const now = new Date();
  const timestamp = now.toLocaleString("en-GB", { dateStyle: "medium", timeStyle: "short", timeZone: "Asia/Bangkok" });

  const cfg = loadConfig();
  
  // 2. Robust Repo Resolution (Fixes duplicate owner bug)
  let org = cfg.org;
  let blogRepo = cfg.blog?.repo || getRepoName();

  // If Orchestrator, force redirect to Team Repo
  const orchestrator = cfg.orchestrator;
  const isOrch = typeof orchestrator === "string" ? true : !!orchestrator; // Basic check
  if (isOrch) {
    blogRepo = "itinfosv/pulse-oracle"; // Target Team Repo
  }

  // Final split if blogRepo is full path
  if (blogRepo.includes("/")) {
    [org, blogRepo] = blogRepo.split("/");
  }

  const repo = getRepoName();
  const repoPath = file.replace(new RegExp(`.*${repo}/`), "");
  const encodedPath = repoPath.replace(/ψ/g, "%CF%88");
  const sourceUrl = `https://github.com/${cfg.org}/${repo}/blob/main/${encodedPath}`;
  const commitUrl = `https://github.com/${cfg.org}/${repo}/commit/${gitInfo.hash}`;

  const provenance = [
    "",
    "---",
    "**Provenance**",
    `- Session: \`${sessionId.slice(0, 8)}\``,
    `- Commit: [\`${gitInfo.hash}\\ sunset](${commitUrl}) — ${gitInfo.message}`,
    `- Author: ${gitInfo.author} (${gitInfo.date.slice(0, 10)})`,
    `- Source: [\`${repoPath}\`](${sourceUrl})`,
    `- Published: ${timestamp} ICT`,
    "",
    "<details><summary>Recent commits</summary>",
    "",
    ...recentCommits.map(c => {
      const [h, ...rest] = c.split(" ");
      return `- [\`${h}\`](https://github.com/${cfg.org}/${repo}/commit/${h}) ${rest.join(" ")}`;
    }),
    "",
    "</details>",
    "",
    "*— Oracle (Pulse)*",
  ].join("\n");

  const fullBody = bodyContent + "\n" + provenance;
  const category = opts.category || cfg.blog?.category || "Announcements";

  console.log(`Publishing: "${title}" → ${org}/${blogRepo} [${category}]`);
  const discussion = await createDiscussion(org, blogRepo, title, fullBody, category);
  console.log(`  Discussion: ${discussion.url}`);

  const hasFrontmatter = content.startsWith("---");
  let updated: string;
  if (hasFrontmatter) {
    updated = content.replace(/^(---[\s\S]*?)---/, (match, fm) => {
      const cleaned = fm.replace(/published:.*\n/g, "");
      return `${cleaned.trimEnd()}\npublished: ${discussion.url}\n---`;
    });
  } else {
    updated = `---\npublished: ${discussion.url}\ndate: ${now.toISOString().slice(0, 10)}\n---\n\n${content}`;
  }
  writeFileSync(file, updated);
  console.log(`  Updated: ${file}`);
}
