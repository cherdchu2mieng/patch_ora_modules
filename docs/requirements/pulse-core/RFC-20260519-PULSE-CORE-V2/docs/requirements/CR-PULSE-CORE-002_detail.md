# Change Request Detail: CR-PULSE-CORE-002

## 1. CR Information
- **Parent RFC**: RFC-20260519-PULSE-CORE-V2
- **Target Module**: pulse-cli
- **Target Branch**: feature/pulse-start-v2
- **Worktree Required**: No - Surgical patching of command logic.
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: New Command / Modification
- **Affected Components**: 
    - `packages/cli/src/pulse.ts` (Register `start` command)
    - `packages/cli/src/commands/start.ts` (New compound command)
    - `packages/cli/src/commands/task.ts` (Refactor to return LocalID)
    - `packages/cli/src/commands/index.ts` (Export `start`)
- **Logic Description**:
    1. **Refactor `pulse task`**:
        - Modify the `task(masterItemIndex)` function to return the created `localIssueId` instead of just printing it.
        - Ensure the anchor `Parent: org/repo#MasterID` is correctly appended to the body.
    2. **Implement `pulse start`**:
        - Create a new command file `start.ts`.
        - The command accepts a `<MasterID>`.
        - Execution Sequence:
            1. Call `await task(masterItemIndex)`.
            2. If successful, capture the returned `localIssueId`.
            3. Call `await go(localIssueId)`.
    3. **Error Handling**:
        - If `task` fails (e.g., already pulled), `start` should check if a local anchor already exists and offer to call `go` on the existing LocalID.

## 3. Impact Assessment
- **Integration Impact**: High cohesion between `task` and `go` commands.
- **Regression Risk**: Low. Uses established anchor logic.

## 4. Acceptance Criteria
- [ ] `pulse start <MasterID>` successfully creates a local issue AND sets it to `In Progress` in one go.
- [ ] Bidirectional links are correctly established on the Master Board.
- [ ] Command fails gracefully if `<MasterID>` is invalid or assigned to another Oracle.


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
