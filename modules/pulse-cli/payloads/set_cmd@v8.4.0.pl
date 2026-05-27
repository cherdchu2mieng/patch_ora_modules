import { gh, getItems, getFields, getProjectId, graphql } from "@pulse-oracle/sdk";
import { getContext, enforceAuth } from "../config";

export async function set(itemIndex: number, ...fieldValues: string[]) {
  try {
    enforceAuth();
    const ctx = getContext();
    const items = await getItems(ctx);
    const fields = await getFields(ctx);
    const projectId = await getProjectId(ctx);

    if (itemIndex < 1 || itemIndex > items.length) {
      console.error(`Item index ${itemIndex} out of range (1-${items.length})`);
      return;
    }

    const item = items[itemIndex - 1];
    console.log(`Setting fields on: "${item.title}"
`);

    let dateIndex = 0;

    for (const fv of fieldValues) {
      let fieldName: string | undefined;
      let value: string;

      if (fv.includes("=")) {
        [fieldName, value] = fv.split("=", 2);
      } else {
        value = fv;
      }

      if (fieldName) {
        const textField = fields.find(
          (f) => f.name.toLowerCase() === fieldName!.toLowerCase() && !f.options && f.type === "ProjectV2Field"
        );
        if (textField && !isDateFieldName(textField.name)) {
          await graphql(`mutation {
            updateProjectV2ItemFieldValue(input: {
              projectId: "${projectId}",
              itemId: "${item.id}",
              fieldId: "${textField.id}",
              value: { text: "${value.replace(/"/g, '\"')}" }
            }) { projectV2Item { id } }
          }`);
          console.log(`  ${textField.name} = ${value}`);
          continue;
        }
      }

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
          console.log(`  ${field.name} = ${opt.name}`);

          if (field.name.toLowerCase() === "oracle") {
            const clientType = opt.name.startsWith("H") ? "Human" : (opt.name.startsWith("A") ? "AI-Team" : null);
            if (clientType) {
              const clientField = fields.find(f => f.name.toLowerCase() === "client");
              const clientOpt = clientField?.options?.find(o => o.name.toLowerCase() === clientType.toLowerCase());
              if (clientField && clientOpt) {
                await gh(
                  "project", "item-edit", "--project-id", projectId,
                  "--id", item.id, "--field-id", clientField.id,
                  "--single-select-option-id", clientOpt.id
                );
                console.log(`  Auto-Client = ${clientOpt.name}`);
              }
            }
          }
          matched = true;
          break;
        }
      }
      if (matched) continue;

      if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
        let dateField;
        if (fieldName) {
          dateField = fields.find(
            (f) => f.name.toLowerCase() === fieldName!.toLowerCase() && f.type === "ProjectV2Field"
          );
        } else {
          const targetName = dateIndex === 0 ? "Start Date" : "Target Date";
          dateField = fields.find((f) => f.name.toLowerCase() === targetName.toLowerCase());
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
          console.log(`  ${dateField.name} = ${value}`);
          continue;
        }
      }
      console.warn(`  ⚠ "${fv}" did not match any field on this project`);
    }
  } catch (e: any) {
    if (e.message?.includes("rate limit exceeded")) {
      console.error("❌ GitHub API Rate Limit Exceeded. Please wait a few minutes before trying again.");
    } else {
      console.error("❌ Failed to execute set command:", e.message);
    }
  }
}

function isDateFieldName(name: string): boolean {
  const lower = name.toLowerCase();
  return lower === "start date" || lower === "target date";
}
