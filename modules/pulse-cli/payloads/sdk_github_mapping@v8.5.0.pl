    extraMap.set(node.id, {
      start: node.startDate?.date || "",
      target: node.targetDate?.date || "",
      worktree: node.worktree?.text || "",
      repo: node.content?.repository?.name || "",
      anchor: node.anchor?.text || "",
    });