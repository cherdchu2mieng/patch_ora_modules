    // 2. Authority Check (Workspace-Based Identity)
    if (!current) {
      console.error("❌ Error: Could not resolve current Oracle identity from workspace folder.");
      return;
    }

    if (assignedOracle !== current.toLowerCase()) {
      console.error(`❌ Authority Denied: Workspace identity (${current}) does not match assigned Oracle (${assignedOracle || 'None'}) on this board.`);
      return;
    }
