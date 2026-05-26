    const projectId = await getProjectId(ctx);
    const fields = await getFields(ctx);
    const statusField = fields.find(f => f.name === "Status");
    const inProgressOpt = statusField?.options?.find(o => o.name === "In Progress");

    if (statusField && inProgressOpt) {
      await gh(
        "project", "item-edit", "--project-id", projectId,
        "--id", item.id, "--field-id", statusField.id,
        "--single-select-option-id", inProgressOpt.id
      );
      console.log(`✅ Status updated to 'In Progress' on Master Board.`);
    }
