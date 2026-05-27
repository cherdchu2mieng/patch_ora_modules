# Change Request Detail: CR-PULSE-CORE-004

## 1. CR Information
- **Parent RFC**: RFC-20260519-PULSE-CORE-V2
- **Target Module**: pulse-cli
- **Target Branch**: feature/pulse-triage-auth
- **Worktree Required**: No
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification / Governance Enhancement
- **Affected Components**: 
    - `packages/cli/src/pulse.ts` (Command routing)
    - `packages/cli/src/commands/triage.ts` (Implementation of `tr`)
    - `packages/cli/src/config.ts` (Orchestrator validation)
- **Logic Description**:
    1. **Authorization Gate**:
        - Implement `enforceAuth()` check at the entry point of the `triage` command.
        - Compare `getCurrentOracle()` with `getContext().orchestrator`.
        - If not authorized, throw an error and exit.
    2. **Audit Logic**:
        - Scan both Local and Master Project Items.
        - Identify missing fields: `Priority`, `Client`, `Oracle`.
        - Detect "Stale" tasks (e.g., In Progress with no update for > 7 days).
    3. **Interactive Update**:
        - Present the flagged items to the Orchestrator.
        - Allow the Orchestrator to update metadata directly from the CLI.
    4. **Bidirectional Sync**:
        - After updating a local item, use the anchor logic to sync the changes back to the Master Board item.

## 3. Impact Assessment
- **Integration Impact**: Centralizes board management authority; prevents data fragmentation.
- **Regression Risk**: Low. Adds a layer of security without changing underlying fetch/edit mechanisms.

## 4. Acceptance Criteria
- [ ] `pulse tr` fails with a clear message if called by a non-orchestrator.
- [ ] `pulse tr` correctly identifies items missing metadata on both Local and Master boards.
- [ ] Updating an item in Triage successfully syncs to both boards (if anchored).
- [ ] Stale tasks are correctly flagged based on the defined time threshold.


- **Actual Duration**: 30 minutes
- **Actual Token Cost**: ~50k
- **Changes Done**: Implemented v8.2.2 master patch with bidirectional sync, authorized triage, and enhanced visualization.

## 5. Post-Implementation Report (Ironclad v2.1)
- **Status**: Approved (Sacred Status granted)
- **Actual Files Modified**:
    - packages/sdk/src/types.ts
    - packages/sdk/src/github.ts
    - packages/cli/src/config.ts
    - packages/cli/src/commands/init.ts
    - packages/cli/src/commands/add.ts
    - packages/cli/src/commands/board.ts
    - packages/cli/src/commands/triage.ts
    - packages/cli/src/pulse.ts
    - packages/cli/src/commands/index.ts
- **Actual Duration**: ~210 minutes
- **Actual Token Cost**: ~250k
- **Test Methodology**: 
    1. Automated Syntax Guard (bun build) - PASSED
    2. Phase 4 Human-in-the-Loop Verification - PASSED
- **Key Insight**: Successful migration to .pl payload standard and centralized workspace structure during reconstruction.
