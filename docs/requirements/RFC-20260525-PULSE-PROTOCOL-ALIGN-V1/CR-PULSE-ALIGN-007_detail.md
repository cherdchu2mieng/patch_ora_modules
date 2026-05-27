# Change Request Detail: CR-PULSE-ALIGN-007

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: close)
- **Execution Skill**: build-patch
- **Status**: Verified 🛡️ (Tested from human = Sacred)

## 2. Technical Scope
- **Nature of Change**: Context-Aware Closure
- **Affected Components**: 
    - `packages/cli/src/commands/close.ts`
- **Key Implementation Details**:
    1. **Closure Restriction**: Blocks closing tasks in `New` status to prevent premature lifecycle termination.
    2. **Smart Context Switching**: 
        - `org: itinfosv` (Management) -> Status: `Closed`
        - Other (Execution) -> Status: `Done`
    3. **SDK Integration**: Utilizes `setFieldOnItem` for robust status synchronization.

## 3. Impact Assessment
- **Clarity**: Distinguishes between "Management Closure" and "Execution Completion" at the status level.
- **Robustness**: Prevents illegal state transitions from `New` directly to closure.

## 4. Acceptance Criteria
- [x] `New` status tasks cannot be closed.
- [x] ITB context uses `Closed` status.
- [x] AIB context uses `Done` status.

## 5. Post-Implementation Report
- **Verified Date**: 2026-05-26
- **Status**: **SACRED LOCKED 🛡️🔒**
- **Files Delivered**: `payloads/v8.4.2/close.ts`
