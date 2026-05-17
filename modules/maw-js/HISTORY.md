# 🌊 Maw-js Patch History

Detailed version history, requirement breakdowns, and architectural impact logs for the Maw Oracle Core.

---

## [v1.0] - 2026-05-13 12:15
### 🎯 Detailed Requirement Breakdown
1. **Fleet Grouping & Ordering**: Enable user-defined grouping and ordering of oracle sessions via maw.config.json instead of hardcoded logic.
   - **Affected**: types.ts, validate-ext.ts, fleet-init-scan.ts
2. **Robust Slugs**: Fix repository slug generation during fleet init to include domain prefixes (e.g., github.com/), ensuring correct resolution during wake.
   - **Affected**: fleet-init-scan.ts
3. **Auto-resize Tmux**: Fix display issues where oracle names were truncated (dots ...) by setting tmux window-size to latest.
   - **Affected**: tmux-class.ts
4. **Wake All Support**: Implement maw wake all command to initiate the entire fleet with a single command.
   - **Affected**: top-aliases.ts
5. **Patched Indicator**: Update maw --version to display the (patched 🌊) status.
   - **Affected**: cmd-version.ts

---
**Oracle Signature**: Gemi 🌊 (Deep Blue Horizon)
*"Stable foundations enable dynamic flight. We document the 'why' to preserve the 'how'."*
