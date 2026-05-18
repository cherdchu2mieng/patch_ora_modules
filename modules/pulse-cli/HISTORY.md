# 🌊 Pulse CLI Patch History

Detailed version history, requirement breakdowns, and architectural impact logs.

---

## [v8.2] - 2026-05-18 2026-05-18 11:15
### 🎯 Detailed Requirement Breakdown
1. **Command: pulse task <ID>**: Enable pulling assigned tasks from the Master Board into local repositories.
   - **Validation**: Strict oracle assignment check (Current Oracle must match Item Oracle).
   - **Cross-Linking**: Automatic generation of `Parent: org/repo#ID` metadata in local issue body.
   - **Bidirectional Sync**: Master Board issue receives a comment linking back to the local task.
2. **Lifecycle Integration**: Registering `task` as a core orchestration command.



## [v7.11] - 2026-05-17 11:30
### 🎯 Detailed Requirement Breakdown
1. **Restoration of Org Mode & Gateway Routing**: Restore the ability to route tasks to external organizational gateways (Pegasus) which was lost in v7.10.
   - **Affected**: pulse.ts (Logic), add.ts (Option injection), config.ts (Context expansion)
2. **Hash Prefix Support (#)**: Support for item numbers prefixed with '#' in pulse set to prevent shell-level comment errors.
   - **Affected**: pulse.ts (Command parsing)
3. **Internal Feature Commenting**: Explicitly mark logic blocks with comments to prevent accidental deletion during future cumulative patches.
   - **Affected**: All patched files

---

## [v7.10] - 2026-05-17 10:45
### 🎯 Detailed Requirement Breakdown
1. **Correct Repository Logic**: Ensure pulse add defaults to the central board repo (pulse-oracle) even when an oracle is assigned.
   - **Affected**: add.ts (Repository resolution)
2. **Secure Authority Enforcement (Option B)**: Lock board management commands (set, triage) to the designated orchestrator only.
   - **Affected**: pulse.ts (Access Guard), add.ts (Conditional assignment)
3. **Automatic Identity Recognition**: Detect current oracle identity from the directory name as a fallback for missing ORACLE_NAME environment variable.
   - **Affected**: config.ts (Identity helper), pulse.ts & add.ts (Integration)
4. **Robust Patching v1.1 Standard**: Implementation of 'Raw String + Literal Replace' protocol to ensure syntax integrity.
   - **Affected**: Patching Infrastructure

---

## [v7.9] - 2026-05-16 22:45
### 🎯 Detailed Requirement Breakdown
1. **Initial Secure Authority**: First attempt to block unauthorized board edits.
   - **Affected**: pulse.ts
### Note
- **WITHDRAWN**: Caused critical syntax error in init.ts due to 'The Newline Trap.'

---

## [v7.8] - 2026-05-15 17:45
### 🎯 Detailed Requirement Breakdown
1. **Fleet Standardization (MASTER Patch)**: Consolidate all previous fixes into one idempotent baseline reset script.
   - **Affected**: All files (via git reset)
2. **Gateway Ingestion Automation**: Automatically pull AI-TEAM issues from the Pegasus gateway into the Master Board during pulse scan.
   - **Affected**: scan.ts
3. **Positional Argument for Body**: Allow the second argument of pulse add to be treated as the issue body.
   - **Affected**: pulse.ts (CLI parsing)

---

## [v7.7] - 2026-05-15 11:30
### 🎯 Detailed Requirement Breakdown
1. **Dynamic Gateway Configuration**: Remove hardcoded organizational routing.
   - **Affected**: config.ts (Interface)
2. **Interactive Init (Org Mode)**: Update pulse init to prompt for and save Gateway details (Repo, Oracle, Client, Priority).
   - **Affected**: init.ts

---

## [v7.6] - 2026-05-14 15:20
### 🎯 Detailed Requirement Breakdown
1. **Centralized Configuration Persistence**: Move configuration to a global system directory to survive repository-level cleanups.
   - **Affected**: config.ts (Path logic)
2. **Local Symlinking**: Automatically create symlinks in oracle repos pointing to the global config.
   - **Affected**: init.ts

---

## [v7.5] - 2026-05-14 18:40
### 🎯 Detailed Requirement Breakdown
1. **Multi-Organization Scope**: Foundation for supporting projects across different GitHub organizations.
   - **Affected**: types.ts, config.ts
2. **Cross-Sync Capability**: Basic plumbing for routing items between fleet project boards.
   - **Affected**: add.ts

---
**Oracle Signature**: Gemi 🌊 (Deep Blue Horizon)
*"Stable foundations enable dynamic flight. We document the 'what' and 'where' to secure the 'now'."*
