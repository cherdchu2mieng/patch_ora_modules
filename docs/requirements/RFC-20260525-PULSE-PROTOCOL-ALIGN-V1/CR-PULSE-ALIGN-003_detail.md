# Change Request Detail: CR-PULSE-ALIGN-003

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Commands: set, start)
- **Execution Skill**: build-patch
- **Status**: Verified 🛡️ (Tested from human = Sacred)

## 2. Technical Scope
- **Nature of Change**: Authority Enforcement & Auto-Client Logic
- **Affected Components**: 
    - [`packages/cli/src/commands/set.ts`](https://github.com/Pulse-Oracle/pulse-cli/blob/main/packages/cli/src/commands/set.ts)
    - [`packages/cli/src/commands/start.ts`](https://github.com/Pulse-Oracle/pulse-cli/blob/main/packages/cli/src/commands/start.ts)
- **Key Implementation Details**:
    1. **Orchestrator Gate (set)**: Added `enforceAuth()` to restrict board modification to the designated Orchestrator.
    2. **Auto-Client Protocol**: Implemented automatic detection of Oracle group:
        - `H*` -> `Human-TEAM`
        - `A*` -> `AI-TEAM`
    3. **Oracle Gate (start)**: Restricted task initiation to the assigned Oracle only. Blocks execution if current workspace identity does not match.
    4. **Surgical Status Update**: `pulse start` now directly updates status to `In Progress` and sets `Start Date` in a single optimized mutation.

## 3. Impact Assessment
- **Security**: Ensures data integrity by preventing unauthorized board changes and task starts.
- **Automation**: Reduces manual overhead for Orchestrators via auto-client mapping.

## 4. Acceptance Criteria
- [x] Only Orchestrator can use `pulse set`.
- [x] Oracle group-based Client mapping (Human-TEAM/AI-TEAM) is operational.
- [x] `pulse start` is restricted to assigned Oracle.
- [x] Successful `start` triggers 'In Progress' status update.

## 5. Post-Implementation Report
- **Verified Date**: 2026-05-26
- **Status**: **SACRED LOCKED 🛡️🔒**
- **Files Delivered**: `payloads/v8.4.2/set.ts`, `payloads/v8.4.2/start.ts`
