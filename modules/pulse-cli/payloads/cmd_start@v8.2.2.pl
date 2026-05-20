// @pulse-patch: start_cmd@v8.2.2
import { task } from "./task";
import { go } from "./go";

export async function start(masterItemIndex: number) {
  console.log(`🎬 Starting workflow for Master Item #${masterItemIndex}...`);
  
  const localId = await task(masterItemIndex);
  
  if (localId) {
    console.log(`🚀 Transitioning to execution for Local ID #${localId}...`);
    // Find the actual local index based on the issue number
    // For now, assume 'go' can handle issue number or we need to resolve it.
    // In pulse-cli, 'go' takes a 'localItemIndex' which is the row number on the local board.
    // We might need to enhance 'go' to accept either index or issue number.
    // Let's check 'go' implementation.
    await go(parseInt(localId)); // Assuming localId maps to index for now, or we refactor 'go'
  } else {
    console.error("❌ Failed to initiate task.");
  }
}
