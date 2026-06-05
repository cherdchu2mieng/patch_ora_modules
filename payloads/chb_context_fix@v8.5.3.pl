export async function chb(rawId: string | number, opts: { delegated?: boolean; returned?: boolean } = {}) {
  console.log("\n  🌊 Pulse CLI Unified Protocol V1 (v8.5.3)");
  console.log("  🔄 Handover Standard Mode (Board-Aware Anchoring)\n");

  const cfg = loadConfig();
  const ctx = getContext();
  const items = await getItems(ctx);

  const itemIndex = typeof rawId === "string" ? parseInt(rawId.replace("#", "")) : rawId;
  if (isNaN(itemIndex) || itemIndex < 1 || itemIndex > items.length) {
    console.error("❌ Error: Item index " + itemIndex + " out of range (1-" + items.length + ")");
    return;
  }

  const item = items[itemIndex - 1];
  
  const { ctx: itbCtx, repo: itbFull } = resolveBoardContext("ITB");
  const { ctx: aibCtx, repo: aibFull } = resolveBoardContext("AIB");
  
  const isITB = ctx.org.toLowerCase() === itbCtx.org.toLowerCase();
  const isAIB = ctx.org.toLowerCase() === aibCtx.org.toLowerCase();

  console.log("  Current Context: " + (isITB ? "IT Master Board" : (isAIB ? "AI Board Team" : "Unknown Board")));

  const orchestratorName = cfg.orchestrator?.oracle || getCurrentOracle() || "pulse";

  let action: "delegated" | "returned" | undefined;
  if (opts.delegated) action = "delegated";
  else if (opts.returned) action = "returned";
  else if (isITB) action = "delegated";
  else if (isAIB) action = "returned";

  if (action === "delegated") {
    if (!isITB && !opts.delegated) {
      console.error("❌ Context Error: Delegation must be performed from the IT Master Board (" + itbFull + ").");
      return;
    }

    if (!item.oracle) {
      console.error("❌ Authority Error: No worker Oracle assigned.");
      return;
    }

    console.log("🔄 Delegating task #" + itemIndex + " to " + aibFull + "...");

    let aibIssueUrl: string;
    try {
      const issueArgs = [
        "issue", "create", "--repo", aibFull, "--title", item.title,
        "--body", "Delegated from IT Master Board (" + itbFull + "#" + itemIndex + ")\n\nOriginal: " + (item.url || "---"),
      ];
      aibIssueUrl = await gh(...issueArgs);
      console.log("  GitHub: ✅ Created issue in " + aibFull);
    } catch (e: any) {
      console.error("❌ GitHub Error: " + e.message);
      return;
    }

    const aibIssueId = aibIssueUrl.trim().split("/").pop();

    // --- ITB UPDATE (Source) ---
    await setFieldOnItem(ctx, item.id, "Status", "Delegated");
    await setFieldOnItem(ctx, item.id, "Priority", "P1");
    await setTextField(ctx, item.id, "Anchor", "AIB-#" + aibIssueId);

    console.log("  Board (ITB): ✅ Status=Delegated, Priority=P1 (Oracle preserved)");
    console.log("  Anchor: AIB-#" + aibIssueId);

    // --- AIB UPDATE (Target) ---
    try {
       const addRes = await gh("project", "item-add", String(aibCtx.projectNumber), "--owner", aibCtx.org, "--url", aibIssueUrl.trim(), "--format", "json");
       const aibItemId = JSON.parse(addRes).id;
       
       await setFieldOnItem(aibCtx, aibItemId, "Status", "New");
       await setFieldOnItem(aibCtx, aibItemId, "Oracle", orchestratorName);
       await setFieldOnItem(aibCtx, aibItemId, "Priority", "P1");
       await setFieldOnItem(aibCtx, aibItemId, "Client", "AI-Team");
       await setTextField(aibCtx, aibItemId, "Anchor", "ITB-#" + itemIndex);
       
       console.log("  Board (AIB): ✅ Bidirectional link established (ITB-#" + itemIndex + " <-> AIB)");
       console.log("  Board (AIB): ✅ Oracle=" + orchestratorName + ", Priority=P1, Client=AI-Team");
    } catch (e) {
       console.log("  ⚠️  Target board update failed (optional).");
    }

    console.log("\n✅ Task delegated successfully.");

  } else if (action === "returned") {
    if (!isAIB && !opts.returned) {
      console.error("❌ Context Error: Return must be performed from the AI Board Team (" + aibFull + ").");
      return;
    }

    if (!item.anchor || !item.anchor.startsWith("ITB-#")) {
      console.error("❌ Anchor Error: No valid ITB anchor found. Cannot return work to Org board.");
      return;
    }

    const itbId = item.anchor.replace("ITB-#", "");
    console.log("⬆️  Returning task #" + itemIndex + " to IT Master Board (ID #" + itbId + ")...");

    // 1. Update AIB Board: Status=Returned, Priority=P1 (Oracle remains UNCHANGED)
    await setFieldOnItem(ctx, item.id, "Status", "Returned");
    await setFieldOnItem(ctx, item.id, "Priority", "P1");

    // 2. Update ITB Board: Status=Closed (Modified as requested)
    try {
      const itbItems = await getItems(itbCtx);
      const itbItem = itbItems[parseInt(itbId) - 1];
      if (itbItem) {
        await setFieldOnItem(itbCtx, itbItem.id, "Status", "Closed");
        console.log("  Board (ITB): ✅ Closed (ID #" + itbId + " updated)");
      }
    } catch (e) {
      console.log("  ⚠️  ITB Board update failed.");
    }

    console.log("  Board (AIB): ✅ Status=Returned, Priority=P1 (Oracle preserved)");
    console.log("\n✅ Work returned and synchronized with IT Master Board.");
  }
}
