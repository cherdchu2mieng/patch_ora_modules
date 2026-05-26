        if (field.name === "Oracle") {
          const clientType = opt.name.startsWith("H") ? "Human-TEAM" : (opt.name.startsWith("A") ? "AI-TEAM" : null);
          if (clientType) {
            const clientField = fields.find(f => f.name === "Client");
            const clientOpt = clientField?.options?.find(o => o.name === clientType);
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
