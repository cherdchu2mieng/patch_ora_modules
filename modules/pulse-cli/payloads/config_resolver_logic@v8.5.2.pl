
/** Resolve Board Context (Org + ProjectNumber) from config */
export function resolveBoardContext(target: "ITB" | "AIB"): { ctx: PulseContext; repo: string } {
  const cfg = loadConfig();
  const board = cfg.board?.[target];
  
  if (!board) {
     const defaultRepo = target === "ITB" ? "itinfosv/pulse-oracle" : (cfg.org + "/pulse-oracle");
     return { ctx: { org: defaultRepo.split("/")[0], projectNumber: cfg.projectNumber }, repo: defaultRepo };
  }

  if (typeof board === "string") {
     return { ctx: { org: board.split("/")[0], projectNumber: cfg.projectNumber }, repo: board };
  }

  return { ctx: { org: board.repo.split("/")[0], projectNumber: board.projectNumber }, repo: board.repo };
}
