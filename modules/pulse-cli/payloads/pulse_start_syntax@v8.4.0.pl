  case "start": {
    const { start } = require("./commands/index");
    if (!args[0]) {
       console.error("Usage: pulse start <master_item_index>");
       process.exit(1);
    }
    await start(parseInt(args[0]));
    break;
  }
