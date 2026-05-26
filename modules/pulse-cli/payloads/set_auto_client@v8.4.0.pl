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
