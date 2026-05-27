  // v8.4.0: Config Pre-check & Default Client
  const configPath = require('path').join(process.cwd(), 'pulse.config.json');
  if (!require('fs').existsSync(configPath)) {
    console.error("❌ Error: pulse.config.json not found in current directory.");
    console.error("💡 Please run 'pulse init' first.");
    process.exit(1);
  }

  const cfg = loadConfig();
  const defaultClient = cfg.org === "itinfosv" ? "Human" : "AI";
