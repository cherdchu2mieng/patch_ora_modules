<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-PULSE-ALIGN-004.v1

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: chb)
- **Execution Skill**: build-patch
- **Status**: Approved (Tested from human = Sacred)

## 2. Technical Scope
- **Nature of Change**: Bidirectional Board Synchronization (Ingress & Return)
- **Affected Components**: 
    - [`packages/cli/src/commands/chb.ts`](https://github.com/Pulse-Oracle/pulse-cli/blob/main/packages/cli/src/commands/chb.ts) (Core logic for delegation and return)
    - [`packages/cli/src/commands/index.ts`](https://github.com/Pulse-Oracle/pulse-cli/blob/main/packages/cli/src/commands/index.ts) (Cumulative export)
    - [`packages/cli/src/pulse.ts`](https://github.com/Pulse-Oracle/pulse-cli/blob/main/packages/cli/src/pulse.ts) (Command routing)

- **Key Implementation Details (Ingress: ITB -> AIB)**:
    1. **Command Name**: Renamed from `och` to `chb` (Change Board).
    2. **Task Delegation Flow**: Moves execution authority from ITB to AIB.
    3. **Authority Check**:
        - **Workspace-Identity Mapping**: Maps Folder (e.g., `gemi-oracle`) to Oracle key (e.g., `gemi`) via `pulse.config.json`.
        - **Oracle Match Gate**: Resolved identity MUST match the task's **`Oracle`** field on the source board (ITB).
    4. **Delegation Option**: `--Delegated` flag initiates the transition.
    5. **Source Board (ITB) Update**: Status `Assigned` -> `In Progress`. Anchor: `AIB-#ID`.
    6. **Target Board (AIB) Update**: Status `Delegated`. Client: `Human-TEAM`. Anchor: `ITB-#ID`.

- **Key Implementation Details (Return: AIB -> ITB)**:
    1. **Board Context Guard**:
        - `--Delegated`: Only allowed on **ITB**.
        - `--Returned`: Only allowed on **AIB**.
    2. **Task Return Flow**:
        - **Trigger**: `pulse chb <index> --Returned`
        - **Authority Check**: 
            - **Workspace-Identity Mapping**: Maps Folder (e.g., `gemi-oracle`) to Oracle key (e.g., `gemi`) via `pulse.config.json`.
            - **Oracle Match Gate**: Resolved identity MUST match the task's **`Oracle`** field on the source board (AIB).
        - **Source Status Gate**: Only for tasks in **`Delegated`** status.
        - **Source Update (AIB)**: Status -> **`Returned`**.
        - **Destination Update (ITB)**: Status -> **`Done`** (using the `ITB-#ID` anchor).
    3. **Smart Cross-Board Lookup**: Parses the Anchor field to identify the corresponding remote ID.

## 3. Impact Assessment
- **Visibility**: Seamless trail from management to execution boards.
- **Reliability**: Closes the task lifecycle loop by synchronizing completion back to the management board.
- **Security**: Mandates Actor-Oracle authority check before delegation and return.

## 4. Acceptance Criteria
### 4.1 Ingress (ITB -> AIB)
- [x] Command `pulse chb <index> --Delegated` initiates delegation only for `Assigned` tasks.
- [x] **Authority Enforcement**: Command `pulse chb --Delegated` is blocked if the current workspace identity does not match the assigned Oracle on ITB.
- [x] Target AIB repository is correctly identified from foundational config (CR-000).
- [x] ITB status changes to `In Progress` only upon successful ingress.
- [x] AIB issue is correctly categorized as `Client: Human-TEAM` and status `Delegated`.

### 4.2 Return (AIB -> ITB)
- [x] Command `pulse chb --Delegated` is blocked on AIB.
- [x] Command `pulse chb --Returned` is blocked on ITB.
- [x] **Authority Enforcement**: Command `pulse chb --Returned` is blocked if the current workspace identity does not match the assigned Oracle on AIB.
- [x] Task return correctly parses Anchor to find ITB item.
- [x] AIB status changes to `Returned` and ITB status changes to `Done`.

## 5. Post-Implementation Report
- **Verified Date**: 2026-05-26
- **Status**: **SACRED LOCKED 🛡️🔒**
- **Result**: **SUCCESS** - Bidirectional flow and workspace-based authority are fully operational.

---
*Refined from CR-PULSE-ALIGN-004 (Bidirectional Sync) 🛡️🔄*
