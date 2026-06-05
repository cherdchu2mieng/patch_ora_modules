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
