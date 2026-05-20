# Change Request Detail: CR-PULSE-CORE-001

## 1. CR Information
- **Parent RFC**: RFC-20260519-PULSE-CORE-V2
- **Target Module**: pulse-cli
- **Target Branch**: feature/pulse-board-v2
- **Worktree Required**: No - Direct surgical patching on existing command files.
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification / Enhancement
- **Affected Components**: 
    - `packages/cli/src/pulse.ts` (Command routing)
    - `packages/cli/src/commands/board.ts` (New command implementation)
    - `packages/sdk/src/github.ts` (GraphQL fetch logic)
- **Logic Description**:
    1. **Fetch Logic**: Upgrade GraphQL query to retrieve all required fields (`Priority`, `Client`, `Oracle`, `Status`, `Dates`).
    2. **Filtering**: Implement a case-insensitive filtering mechanism that checks command arguments against `Oracle`, `Client`, `Priority`, and `Status` fields.
    3. **Responsive Table**:
        - Detect terminal width using `process.stdout.columns`.
        - Define column ratios and truncate the `Title` column dynamically to fit the width.
        - Apply ANSI colors (using a lightweight utility or raw codes) for `Priority` (P0=Red) and `Status` (Done=Green).
    4. **Display**: Render the table using `console.log` with a clean ASCII border or simple padding.

## 3. Impact Assessment
- **Integration Impact**: Enhances visibility for the entire fleet; no breaking changes to SDK.
- **Regression Risk**: Low. This is primarily a visualization upgrade.

## 4. Acceptance Criteria
- [ ] `pulse board` displays all 9 columns correctly.
- [ ] Filtering works as expected (e.g., `pulse board P0` only shows high-priority items).
- [ ] Table does not break or overflow when terminal width is narrow (truncation works).
- [ ] Thai characters in titles are rendered correctly without breaking table alignment.


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
