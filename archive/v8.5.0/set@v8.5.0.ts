// @pulse-patch: cmd_set_v1@v8.5.0
import { gh, getItems, getFields, getProjectId, graphql } from "@pulse-oracle/sdk";
import { getContext, enforceAuth, loadConfig } from "../config";

export async function set(rawId: string | number, ...fieldValues: string[]) {
  // 1. Authority Gate
  enforceAuth();

  console.log("\n  🌊 Pulse CLI Unified Protocol V1 (v8.5.0)");
  console.log("  🛠️  Board Modification Mode\n");

  const ctx = getContext();
  const items = await getItems(ctx);
  const fields = await getFields(ctx);
  const projectId = await getProjectId(ctx);
  const cfg = loadConfig();

  // 2. ID Parsing (Support #123)
  const itemIndex = typeof rawId === "string" ? parseInt(rawId.replace("#", "")) : rawId;

  if (isNaN(itemIndex) || itemIndex < 1 || itemIndex > items.length) {
    console.error(`❌ Error: Item index ${itemIndex} out of range (1-${items.length})`);
    return;
  }

  const item = items[itemIndex - 1];
  console.log(`Updating: "${item.title}"`);

  let dateIndex = 0;

  for (const fv of fieldValues) {
    let fieldName: string | undefined;
    let value: string;

    if (fv.includes("=")) {
      [fieldName, value] = fv.split("=", 2);
    } else {
      value = fv;
      
      // Auto-detection logic
      if (/^P[0-3]$/i.test(value)) {
        fieldName = "Priority";
        value = value.toUpperCase();
      } else if (/^(New|In Progress|Done|Closed|Paused)$/i.test(value)) {
        fieldName = "Status";
        // Map common casings
        const map: Record<string, string> = {
          new: "New", "in progress": "In Progress", done: "Done", closed: "Closed", paused: "Paused"
        };
        value = map[value.toLowerCase()] || value;
      } else if (/^(Human|AI|H\*|A\*)$/i.test(value)) {
        fieldName = "Client";
        if (value.toLowerCase() === "human") value = "Human";
        if (value.toLowerCase() === "ai") value = "AI";
      } else {
        // Check if it matches an Oracle name
        const oracleRepos = cfg.oracleRepos || {};
        const match = Object.keys(oracleRepos).find(k => k.toLowerCase() === value.toLowerCase());
        if (match) {
          fieldName = "Oracle";
          value = match.charAt(0).toUpperCase() + match.slice(1).toLowerCase();
        }
      }
    }

    // Try SingleSelect fields
    let matched = false;
    for (const field of fields) {
      if (!field.options) continue;
      if (fieldName && field.name.toLowerCase() !== fieldName.toLowerCase()) continue;

      const opt = field.options.find((o) => o.name.toLowerCase() === value.toLowerCase());
      if (opt) {
        await gh(
          "project", "item-edit", "--project-id", projectId,
          "--id", item.id, "--field-id", field.id,
          "--single-select-option-id", opt.id
        );
        console.log(`  ✅ ${field.name} = ${opt.name}`);
        matched = true;
        break;
      }
    }
    if (matched) continue;

    // Try DATE field
    if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
      let dateField;
      if (fieldName) {
        dateField = fields.find(
          (f) => f.name.toLowerCase() === fieldName!.toLowerCase() && f.type === "ProjectV2Field"
        );
      } else {
        const targetName = dateIndex === 0 ? "Start Date" : "Target Date";
        dateField = fields.find((f) => f.name === targetName);
        dateIndex++;
      }
      if (dateField) {
        await graphql(`mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: "${projectId}",
            itemId: "${item.id}",
            fieldId: "${dateField.id}",
            value: { date: "${value}" }
          }) { projectV2Item { id } }
        }`);
        console.log(`  ✅ ${dateField.name} = ${value}`);
        continue;
      }
    }

    // Try TEXT field (requires field=value or no options)
    if (fieldName) {
      const textField = fields.find(
        (f) => f.name.toLowerCase() === fieldName!.toLowerCase() && !f.options
      );
      if (textField) {
        await graphql(`mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: "${projectId}",
            itemId: "${item.id}",
            fieldId: "${textField.id}",
            value: { text: "${value.replace(/"/g, '\\"')}" }
          }) { projectV2Item { id } }
        }`);
        console.log(`  ✅ ${textField.name} = ${value}`);
        continue;
      }
    }

    console.warn(`  ⚠️  "${fv}" did not match any field or pattern`);
  }
  console.log("\n✅ Board metadata updated successfully.");
}