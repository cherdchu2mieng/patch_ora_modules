  case "blog": {
    enforceOrchestrator();
    if (!args[0]) {
      console.error("Usage: pulse blog <file.md> [patchWorkspaceUrl] [--title <title>] [--category <category>]");
      process.exit(1);
    }
    const wsUrl = args[1] && !args[1].startsWith("-") ? args[1] : undefined;
    await blog(args[0], {
      title: parseFlag("--title"),
      category: parseFlag("--category"),
      patchWorkspace: wsUrl
    });
