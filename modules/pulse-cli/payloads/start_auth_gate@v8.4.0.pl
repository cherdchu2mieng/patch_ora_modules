  const ctx = getContext();
  const allItems = await getItems(ctx);
  if (masterItemIndex < 1 || masterItemIndex > allItems.length) {
    console.error(`Item index ${masterItemIndex} out of range (1-${allItems.length})`);
    return;
  }
  const item = allItems[masterItemIndex - 1];
  const assignedOracle = item.oracle;
  const current = getCurrentOracle();

  if (assignedOracle && current && assignedOracle.toLowerCase() !== current.toLowerCase()) {
    console.error(`❌ Authority Denied: This task is assigned to '${assignedOracle}', but you are '${current}'.`);
    return;
  }
