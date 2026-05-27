  case "och": {
    const { och } = require("./commands/index");
    if (!args[0]) {
      console.error("Usage: pulse och <master_item_index> [target_repo]");
      process.exit(1);
    }
    await och(parseInt(args[0]), args[1]);
    break;
  }
