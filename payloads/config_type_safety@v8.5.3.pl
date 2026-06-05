
/** Get the board repository (String or Object) safely */
export function getBoardRepo(target: "ITB" | "AIB"): string {
  const cfg = loadConfig();
  const board = cfg.board?.[target];
  if (!board) return target === "ITB" ? "itinfosv/pulse-oracle" : `${cfg.org}/pulse-oracle`;
  return typeof board === "string" ? board : board.repo;
}

/** Get the board project number safely */
export function getBoardProject(target: "ITB" | "AIB"): number {
  const cfg = loadConfig();
  const board = cfg.board?.[target];
  if (!board) return cfg.projectNumber;
  return typeof board === "string" ? cfg.projectNumber : board.projectNumber;
}
