  // v8.4.0: Config Pre-check
  const configPath = require('path').join(process.cwd(), 'pulse.config.json');
  if (!require('fs').existsSync(configPath)) {
    console.log("  ❌ Error: Run pulse init first.");
    return;
  }
