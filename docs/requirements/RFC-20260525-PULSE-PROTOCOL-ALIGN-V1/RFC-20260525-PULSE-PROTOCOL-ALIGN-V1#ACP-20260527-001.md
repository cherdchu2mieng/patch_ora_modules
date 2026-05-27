# Final Cumulative Test Plan (ACP-20260527-001)
**RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
**Project**: Pulse-CLI Enhancement
**Target Version**: v8.4.2
**Patch Workspace**: [/home/a2it49072/ghq/github.com/cherdchu2mieng/patch_ora_modules](https://github.com/cherdchu2mieng/patch_ora_modules)

## Objective
To empirically verify the end-to-end stability and integration of all Change Requests (CR-000 to CR-007.v1) within the `PULSE-PROTOCOL-ALIGN-V1` specification before final synchronization and delivery.

## Prerequisites
- Both `itinfosv/pulse-oracle` (ITB) and your personal AIB board are active.
- `pulse-cli` is running from the target repository with the injected `v8.4.2` payloads.
- Your local workspace folder matches your assigned Oracle name (for Authority Gate testing).

---

## Scenario 0: Foundational Setup & Identity
*Tests integration of CR-000 (init).*

1.  **System Initialization**:
    *   **Action**: Delete (or backup) your local `pulse.config.json`. Run `pulse init`.
    *   **Expected**: The command creates a new `pulse.config.json`.
    *   **Verification**: Verify that the `org`, `projectNumber`, and `oracleRepos` are correctly populated. Confirm the `orchestrator` block points to Gemi.
2.  **Identity Resolution**:
    *   **Action**: Run `pulse board`.
    *   **Expected**: Command should correctly identify your current Oracle name based on the workspace folder path.

## Scenario 1: The Core Lifecycle (Ingress to Return)
*Tests integration of CR-004 (chb), CR-003 (start), and CR-001 (add).*

1.  **Ingress (ITB -> AIB)**:
    *   **Action**: Identify a task assigned to you on ITB. Run `pulse chb <#> --Delegated`.
    *   **Expected**: Command succeeds. Task on ITB changes to `In Progress` with Anchor (`AIB-#X`). Task on AIB is created with Status `Delegated` and Client `Human-TEAM`.
2.  **Start Execution (AIB)**:
    *   **Action**: Run `pulse start <#>` on the newly created AIB task.
    *   **Expected**: Task status on AIB changes to `In Progress`. Start Date is recorded.
3.  **Return (AIB -> ITB)**:
    *   **Action**: Run `pulse chb <#> --Returned` on AIB.
    *   **Expected**: Task status on AIB changes to `Returned`. Task status on ITB automatically changes to `Done`.

## Scenario 2: Orchestrator Broadcast (Team Sync)
*Tests integration of CR-006.v1 (blog).*

1.  **Orchestrator Broadcast**:
    *   **Action**: Ensure your identity is marked as an Orchestrator. Run `pulse blog <markdown_file>`.
    *   **Expected**: Post is successfully published to `itinfosv/pulse-oracle` Discussions. Provenance (Commit/Session) is appended to the body. Local file frontmatter is updated with the URL.

## Scenario 3: Authority and Security Gates
*Tests integration of CR-007.v1 (close) and Authority Enforcement.*

1.  **Identity Spoofing Block**:
    *   **Action**: Attempt to run `pulse close <#>` on a task assigned to a *different* Oracle.
    *   **Expected**: Command is blocked. Console displays `❌ Authority Error`.
2.  **Premature Closure Block**:
    *   **Action**: Attempt to run `pulse close <#>` on a task with status `New`.
    *   **Expected**: Command is blocked. Console displays error regarding 'New' status.
3.  **Context-Aware Closure**:
    *   **Action**: Run `pulse close <#>` on an eligible task in the ITB context (`org: itinfosv`).
    *   **Expected**: Task status changes to `Closed` (not `Done`).

---

**Human Tester Instruction**:
Please execute the scenarios above in the Target Repo. If all expected outcomes are verified, reply with:
> **"Final Test: Passed"** 
*(This will trigger Phase 6: Documentation & Sync)*
