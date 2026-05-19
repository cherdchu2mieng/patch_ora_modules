  case "keyword":
  case "kw": {
    const { keyword } = require("./commands/index");
    await keyword(args);
    break;
  }
  case "task":
  case "tk": {
    const { task } = require("./commands/index");
    if (!args[0]) {
       console.error("Usage: pulse task <master_item_index>");
       process.exit(1);
    }
    await task(parseInt(args[0]));
    break;
  }
  case "go": {
    const { go } = require("./commands/index");
    if (!args[0]) {
       console.error("Usage: pulse go <master_item_index>");
       process.exit(1);
    }
    await go(parseInt(args[0]));
    break;
  }
  case "done": {
    const { done } = require("./commands/index");
    if (!args[0]) {
       console.error("Usage: pulse done <local_item_index>");
       process.exit(1);
    }
    await done(parseInt(args[0]));
    break;
  }
