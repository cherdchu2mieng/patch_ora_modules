// @pulse-patch: blog_target_itb@v8.4.2r6
import { readFileSync, writeFileSync } from "fs";
import { basename } from "path";
import { createDiscussion } from "@pulse-oracle/sdk";
import type { BlogOpts } from "@pulse-oracle/sdk";
import { getContext, getRepoName, loadConfig } from "../config";

export async function blog(file: string, opts: BlogOpts = {}) {
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
      const result = Bun.spawnSync(
        ["git", "log", "--oneline", "-5", "--format=%h %s"],
        { stdout: "pipe" }
      );
      return new TextDecoder().decode(result.stdout).trim().split("\n");
    } catch { return []; }
  })();
  const now = new Date();
  const timestamp = now.toLocaleString("en-GB", { dateStyle: "medium", timeStyle: "short", timeZone: "Asia/Bangkok" });

  const cfg = loadConfig();
  const org = ctx.org;
const blogRepo = cfg.blog?.repo || (typeof cfg.board === "object" ? cfg.board.ITB : "itinfosv/pulse-oracle");
  const [targetOrg, targetRepo] = blogRepo.includes("/") ? blogRepo.split("/") : [org, blogRepo];
  const repo = getRepoName();
  
  // Robust Path Detection
  let repoPath = file.includes("ψ/writing/") 
    ? "ψ/writing/" + file.split("ψ/writing/")[1] 
    : file.replace(new RegExp(`.*${repo}/`), "");
    
  let sourceUrl = `https://github.com/${org}/${repo}/blob/master/${repoPath.replace(/ψ/g, "%CF%88")}`;

  const patchWs = opts.patchWorkspace || cfg.patchWorkspace;
  if (patchWs && repoPath.startsWith("ψ/writing/")) {
    const mappedPath = "docs/requirements/" + repoPath.replace(/^ψ\/writing\//, "");
    const wsBase = patchWs.replace(/\/$/, "");
    
    if (wsBase.includes("/blob/")) {
      sourceUrl = `${wsBase}/${mappedPath.replace(/ψ/g, "%CF%88")}`;
    } else {
      sourceUrl = `${wsBase}/blob/master/${mappedPath.replace(/ψ/g, "%CF%88")}`;
    }
    repoPath = mappedPath;
    console.log(`  Traceability: mapped to Patch Workspace 🛡️`);
  }
  const commitUrl = `https://github.com/${org}/${repo}/commit/${gitInfo.hash}`;

  const provenance = [
    "",
    "---",
    "**Provenance**",
    patchWs ? `- Patch Workspace: ${patchWs}` : "",
    `- Commit: [\`${gitInfo.hash}\`](${commitUrl}) — ${gitInfo.message}`,
    `- Author: ${gitInfo.author} (${gitInfo.date.slice(0, 10)})`,
    `- Source: ${sourceUrl}`,
    `- Published: ${timestamp} ICT`,
    "",
    "<details><summary>Recent commits</summary>",
    "",
    ...recentCommits.map(c => {
      const [h, ...rest] = c.split(" ");
      return `- [\`${h}\`](https://github.com/${org}/${repo}/commit/${h}) ${rest.join(" ") }`;
    }),
    "",
    "</details>",
    "",
    "*— Oracle (Pulse)*",
  ].filter(Boolean).join("\n");

  const fullBody = bodyContent + "\n" + provenance;

  const category = opts.category || cfg.blog?.category || "Show and tell";
  console.log(`Publishing: \"${title}\" → ${targetOrg}/${targetRepo} [${category}]`);
  const discussion = await createDiscussion(targetOrg, targetRepo, title, fullBody, category);
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

  console.log(`  Provenance: embedded in body`);
}
