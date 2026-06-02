import { gh, getItems, ensureLabel } from "@pulse-oracle/sdk";
import { getContext, getCurrentOracle } from "../config";
import * as path from "path";

export async function task(masterItemIndex: number): Promise<string | undefined> {
  const ctx = getContext();
  const currentOracle = getCurrentOracle();
  const items = await getItems(ctx);

  if (masterItemIndex < 1 || masterItemIndex > items.length) {
    console.error(`❌ Error: Master item index ${masterItemIndex} out of range (1-${items.length})`);
    return;
  }

  const masterItem = items[masterItemIndex - 1];
  
  if (!currentOracle || masterItem.oracle?.toLowerCase() !== currentOracle.toLowerCase()) {
    console.error(`❌ Authority Error: Item #${masterItemIndex} is assigned to '${masterItem.oracle || 'none'}', not '${currentOracle || 'unknown'}'.`);
    return;
  }

  const currentRepoName = path.basename(process.cwd());
  const searchPattern = `Parent: ${ctx.org}/pulse-oracle#${masterItemIndex}`;
  
  try {
    const existingLocal = await gh("issue", "list", "--repo", `${ctx.org}/${currentRepoName}`, "--search", `"${searchPattern}"`, "--json", "number");
    const found = JSON.parse(existingLocal);
    if (found.length > 0) {
       console.log(`ℹ️  Item #${masterItemIndex} already has a local cross-linked issue (#${found[0].number}) in this repository.`);
       return String(found[0].number);
    }
  } catch (e) {}

  console.log(`📥 Pulling task: "${masterItem.title}" to ${currentRepoName}...`);

  const targetRepo = `${ctx.org}/${currentRepoName}`;
  await ensureLabel(targetRepo, `oracle:${currentOracle}`);

  const localIssueBody = [
    (masterItem as any).body || "No description provided.",
    "",
    "---",
    `🔗 **Cross-Link**`,
    `Parent: ${ctx.org}/pulse-oracle#${masterItemIndex}`
  ].join("\n");

  const issueUrl = await gh("issue", "create", "--repo", targetRepo, "--title", masterItem.title, "--body", localIssueBody);
  const localIssueId = issueUrl.trim().split("/").pop();
  console.log(`✅ Created local Issue #${localIssueId} in ${targetRepo}`);

  // Bidirectional link (Master -> Local)
  const masterIssueUrl = (masterItem as any).content?.url;
  if (masterIssueUrl) {
    const updateMsg = `✅ Task pulled to local: ${targetRepo}#${localIssueId}`;
    await gh("issue", "comment", masterIssueUrl, "--body", updateMsg);
    console.log(`🔗 Bidirectional link established on Master Board.`);
  }

  return localIssueId;
}
