  if (opts.client) {
    try { await setFieldOnItem(ctx, addedItemId, "Client", opts.client); console.log(`Client: ${opts.client}`); } catch (e) {}
  }
  if (opts.priority) {
    try { await setFieldOnItem(ctx, addedItemId, "Priority", opts.priority); console.log(`Priority: ${opts.priority}`); } catch (e) {}
  }
  if (opts.oracle) {
    try { await setFieldOnItem(ctx, addedItemId, "Oracle", opts.oracle); console.log(`Oracle: ${opts.oracle}`); } catch (e) {}
  }
