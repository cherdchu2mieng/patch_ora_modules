       await setFieldOnItem(aibCtx, aibItemId, "Status", "New");
       await setFieldOnItem(aibCtx, aibItemId, "Priority", "P1");
       await setFieldOnItem(aibCtx, aibItemId, "Client", "AI-Team");
       await setTextField(aibCtx, aibItemId, "Anchor", "ITB-#" + itemIndex);
       
       console.log("  Board (AIB): ✅ Bidirectional link established (ITB-#" + itemIndex + " <-> AIB)");
       console.log("  Board (AIB): ✅ Priority=P1, Client=AI-Team");
