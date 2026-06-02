import { readFileSync, writeFileSync } from "fs";
import { basename } from "path";
import { createDiscussion } from "@pulse-oracle/sdk";
import type { BlogOpts } from "@pulse-oracle/sdk";
import { getContext, getRepoName, loadConfig, enforceAuth } from "../config";

export async function blog(file: string, opts: BlogOpts = {}) {
  // 1. Authority Gate
  enforceAuth();

  console.log("\n  🌊 Pulse CLI Unified Protocol V1 (v8.5.0)");
  console.log("  📢 Orchestrator Broadcast Mode\n");

  const ctx = getContext();
  const content = readFileSync(file, "utf-8");

  // 2. Frontmatter & Title Parsing
  const title = opts.title || content.match(/^##\s+(.+)$/m)?.[1] || content.match(/^title:\s*(.+)$/mi)?.[1] || basename(file, ".md");
  const bodyContent = content.replace(/^---[\s\S]*?---\n*/m, "").trim();

  // 3. Provenance Information
  const gitInfo = (() => {
    try {
      const fmt = "%h\t%s\t%an\t%aI";
      const result = Bun.spawnSync(["git", "log", "-1", `--format=${fmt}`], { stdout: "pipe" });
      const [hash, message, author, date] = new TextDecoder().decode(result.stdout).trim().split("\t");
      return { hash, message, author, date };
    } catch { return { hash: "unknown", message: "no git info", author: "unknown", date: new Date().toISOString() }; }
  })();
  
  const now = new Date();
  const timestamp = now.toLocaleString("en-GB", { dateStyle: "medium", timeStyle: "short", timeZone: "Asia/Bangkok" });

  const cfg = loadConfig();
  const org = ctx.org;
  const blogRepo = cfg.blog?.repo || cfg.board?.ITB || "itinfosv/pulse-oracle";
  const [targetOrg, targetRepo] = blogRepo.includes("/") ? blogRepo.split("/") : [org, blogRepo];
  const repo = getRepoName();
  
  // 4. Remote Traceability (Path Mapping)
  let repoPath = file.includes("ψ/writing/") 
    ? "ψ/writing/" + file.split("ψ/writing/")[1] 
    : file.replace(new RegExp(`.*${repo}/`), "");
    
  let sourceUrl = `https://github.com/${org}/${repo}/blob/master/${repoPath.replace(/ψ/g, "%CF%88")}`;

  const patchWs = opts.patchWorkspace || cfg.patchWorkspace;
  if (patchWs && repoPath.startsWith("ψ/writing/")) {
    const mappedPath = "docs/requirements/" + repoPath.replace(/^ψ\/writing\//, "");
    const wsBase = patchWs.replace(/\/$/, "");
    
    // Convert to direct GitHub URL
    if (wsBase.includes("/blob/")) {
      sourceUrl = `${wsBase}/${mappedPath.replace(/ψ/g, "%CF%88")}`;
    } else {
      sourceUrl = `${wsBase}/blob/main/${mappedPath.replace(/ψ/g, "%CF%88")}`;
    }
    console.log(`  Traceability: ✅ Mapped to Patch Workspace 🛡️`);
  }

  const commitUrl = `https://github.com/${org}/${repo}/commit/${gitInfo.hash}`;

  // 5. Build Content with V1 Branding
  const provenance = [
    "",
    "---",
    "**Provenance (Traceability)**",
    patchWs ? `- **Patch Workspace**: ${patchWs}` : "",
    `- **Source**: [${repoPath}](${sourceUrl})`,
    `- **Commit**: [\`${gitInfo.hash}\`](${commitUrl}) — ${gitInfo.message}`,
    `- **Author**: ${gitInfo.author} (${gitInfo.date.slice(0, 10)})`,
    `- **Published**: ${timestamp} ICT`,
    "",
    "🌊 *Published via Pulse Unified Protocol V1 (v8.5.0)*",
  ].filter(Boolean).join("\n");

  const fullBody = bodyContent + "\n" + provenance;

  // 6. GraphQL Execution
  const category = opts.category || content.match(/^category:\s*(.+)$/mi)?.[1] || cfg.blog?.category || "Announcements";
  
  console.log(`Publishing: \"${title}\"`);
  console.log(`  Target: ${targetOrg}/${targetRepo} [${category}]`);
  
  try {
    const discussion = await createDiscussion(targetOrg, targetRepo, title, fullBody, category);
    console.log(`  Discussion: ✅ ${discussion.url}`);

    // Update local file with link
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
    console.log(`  Status: ✅ Mapped locally`);
    
    console.log(`\n✅ Content successfully published with remote traceability.`);

  } catch (e: any) {
    console.error(`❌ Broadcast Error: ${e.message}`);
  }
}
