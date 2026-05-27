# Change Request Detail: CR-PULSE-CORE-003

## 1. CR Information
- **Parent RFC**: RFC-20260519-PULSE-CORE-V2
- **Target Module**: pulse-cli
- **Target Branch**: feature/pulse-sync-closure
- **Worktree Required**: No
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification / Enhancement
- **Affected Components**: 
    - `packages/cli/src/pulse.ts` (Alias `done` to `close`)
    - `packages/cli/src/commands/go.ts` (Sync enhancement)
    - `packages/cli/src/commands/close.ts` (New command based on `done`)
- **Logic Description**:
    1. **`pulse go` (Enhancement)**:
        - Ensure status "In Progress" is applied to both Local Project Item and Master Project Item (via anchor).
        - Verify that the Master Board sync happens immediately after the Local update.
    2. **`pulse close` (Symmetrical Closure)**:
        - Identify the Master ID via the anchor in the local issue body.
        - **Local Actions**:
            - Set Local Project Status to "Done".
            - Close the local GitHub Issue using `gh issue close`.
        - **Master Actions**:
            - Set Master Project Status to "Done".
        - **Cleanup (Operational)**:
            - Check if a worktree exists for this task.
            - Prompt: `"Task completed. Delete local worktree? (y/N)"`.
    3. **Common Sync Module**: Extract the "Anchor-to-MasterID" resolution logic into a helper function to ensure consistency across all commands.

## 3. Impact Assessment
- **Integration Impact**: Reliable status reporting across the fleet.
- **Regression Risk**: Moderate. Requires careful handling of the `gh` CLI calls and API rate limits.

## 4. Acceptance Criteria
- [ ] `pulse go <LocalID>` updates status to "In Progress" on both boards.
- [ ] `pulse close <LocalID>` updates status to "Done" on both boards.
- [ ] `pulse close <LocalID>` successfully closes the local GitHub issue.
- [ ] The command handles missing anchors gracefully (only updates Local).


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
