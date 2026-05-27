      // Update AIB Board
      try {
        const tParts = targetRepo.split("/");
        const tProj = await gh("project", "view", "1", "--owner", tParts[0], "--format", "json");
        const tProjId = JSON.parse(tProj).id;
        const rawFields = await gh("project", "field-list", "1", "--owner", tParts[0], "--format", "json");
        const fields = JSON.parse(rawFields).fields;
        const addRes = await gh("project", "item-add", "1", "--owner", tParts[0], "--url", issueUrl.trim(), "--format", "json");
        const tItemId = JSON.parse(addRes).id;

        const mutations = [];
        const sF = fields.find(f => f.name.toLowerCase() === "status");
        const dOpt = sF?.options?.find(o => o.name.toLowerCase() === "delegated");
        if (sF && dOpt) mutations.push(`uS: updateProjectV2ItemFieldValue(input: { projectId: "${tProjId}", itemId: "${tItemId}", fieldId: "${sF.id}", value: { singleSelectOptionId: "${dOpt.id}" } }) { projectV2Item { id } }`);
        
        const cF = fields.find(f => f.name.toLowerCase() === "client");
        const cOpt = cF?.options?.find(o => o.name.toLowerCase() === "human-team");
        if (cF && cOpt) mutations.push(`uC: updateProjectV2ItemFieldValue(input: { projectId: "${tProjId}", itemId: "${tItemId}", fieldId: "${cF.id}", value: { singleSelectOptionId: "${cOpt.id}" } }) { projectV2Item { id } }`);

        const aF = fields.find(f => f.name.toLowerCase() === "anchor" || f.name.toLowerCase() === "anchar");
        if (aF) mutations.push(`uA: updateProjectV2ItemFieldValue(input: { projectId: "${tProjId}", itemId: "${tItemId}", fieldId: "${aF.id}", value: { text: "${anchorVal}" } }) { projectV2Item { id } }`);

        if (mutations.length > 0) await graphql(`mutation { ${mutations.join(" ")} }`);
        console.log("✅ AIB Board Initialized.");
      } catch (e: any) { console.warn("  ⚠️ AIB update skipped:", e.message); }
