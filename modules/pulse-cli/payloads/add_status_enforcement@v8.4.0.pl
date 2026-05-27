  // v8.4.0: Enforce Status=New and Default Client
  try {
    await setFieldOnItem(ctx, addedItemId, "Status", "New");
    console.log("Status: New");
    
    const clientValue = opts.client || defaultClient;
    await setFieldOnItem(ctx, addedItemId, "Client", clientValue);
    console.log("Client: " + clientValue);
  } catch (e) {
    console.log("⚠️ Field sync: skipped (some fields may be missing on this project)");
  }
