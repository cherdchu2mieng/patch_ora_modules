  case "add":
  case "a": {
    const title = args[0];
    if (!title) {
      console.error("Usage: pulse add <title> [body] [--priority <P0-P3>] [--type <task|bug|feature>]");
      process.exit(1);
    }
    const positionalBody = args[1] && !args[1].startsWith("-") ? args[1] : undefined;
    
    await add(title, {
      body: positionalBody || parseFlag("--body"),
      type: parseFlag("--type"),
      priority: parseFlag("--priority"),
    });
    break;
  }
