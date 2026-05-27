<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-PULSE-ALIGN-007.v1

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: close)
- **Execution Skill**: build-patch
- **Status**: Approved (Tested from human = Sacred)

## 2. Technical Scope
- **Nature of Change**: Authority Enforcement Refinement (Oracle Identity Gate)
- **Affected Components**: 
    - [`packages/cli/src/commands/close.ts`](https://github.com/Pulse-Oracle/pulse-cli/blob/main/packages/cli/src/commands/close.ts)
- **Key Implementation Details**:
    1. **Oracle Authority Gate (NEW 🛡️)**: 
        - Add identity verification before closing a task.
        - The current actor (resolved via `getCurrentOracle()`) MUST match the value in the **`Oracle`** field of the task being closed.
        - Block execution with an authority error if they do not match.
    2. **Closure Restriction (Sacred 🛡️)**: Maintain the block on closing tasks in `New` status to prevent premature lifecycle termination.
    3. **Context-Aware Status (Sacred 🛡️)**: 
        - `org: itinfosv` (Management) -> Status: `Closed`
        - Other (Execution) -> Status: `Done`
    4. **SDK Integration**: Utilizes `setFieldOnItem` for robust status synchronization.

## 3. Impact Assessment
- **Security**: Ensures that only the assigned Oracle can declare a task as finished, preventing unauthorized task closure.
- **Data Integrity**: Maintains the distinction between "Management Closure" and "Execution Completion" while enforcing ownership.

## 4. Acceptance Criteria
- [ ] Command `pulse close` is blocked if the current actor is not the assigned Oracle.
- [ ] Tasks in `New` status cannot be closed.
- [ ] ITB context (`itinfosv`) correctly uses `Closed` status.
- [ ] AIB context correctly uses `Done` status.
- [ ] Associated GitHub issues are automatically closed.

## 5. Post-Implementation Report
*To be filled after implementation.*

---
*Refined from CR-PULSE-ALIGN-007 (Context-Aware Closure) 🛡️🔄*
