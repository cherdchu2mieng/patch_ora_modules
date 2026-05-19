# Pulse CLI Specification: v8.2.1 (Ironclad Standard)

## 1. Document Control
| Field | Detail |
| :--- | :--- |
| **Document ID** | PRD-PULSE-008.2.1 |
| **Version** | v8.2.1 |
| **Status** | Approved (Tested from human = Sacred) |
| **Requester** | cherdchu2mieng (Human) |
| **Architect/Author** | Gemi Oracle 🌊 |
| **Date Created** | 2026-05-19 |

## 2. Executive Summary
**Objective**: To stabilize the `pulse init` and `pulse kw sync` commands, ensuring they reliably handle both User and Organizational scopes without logic regressions or prompt bleed. This version establishes the "Stability Protocol" as a foundational operational constraint.

## 3. Scope
- **In-Scope**: Refactoring `packages/cli/src/commands/init.ts` and `packages/cli/src/commands/keyword.ts`. Enhancing `patch_pulse.sh` for reliable injection.
- **Out-of-Scope**: Modifications to GitHub API SDK, changes to UI formatting of the Master Board.

## 4. Functional Requirements (FR)
| ID | Requirement | Priority |
| :--- | :--- | :--- |
| **FR-1** | `pulse init` MUST support distinct `[U]ser` and `[O]rg` initialization paths. | P0 |
| **FR-2** | In User mode, the system MUST prompt `Add oracle repo <name>? (Y/n)` iteratively for each discovered repo. | P0 |
| **FR-3** | In User mode, the system MUST NOT prompt for Gateway configuration. | P0 |
| **FR-4** | In Org mode, the system MUST prompt for Gateway details (Repo, Oracle, Client, Priority) and ask for a Target User to sync. | P0 |
| **FR-5** | In Org mode, discovered repositories MUST be auto-added without interactive confirmation. | P0 |
| **FR-6** | `pulse kw sync` MUST dynamically detect the Oracle identity from the current directory or `ORACLE_NAME` env. | P0 |
| **FR-7** | Keyword extraction MUST strip markdown formatting (e.g., `**English**:`) and save cleanly to the `routing.keyword` array. | P0 |

## 5. Non-Functional Requirements (NFR)
- **NFR-1 (Stability)**: "Tested from human = Sacred" - Verified logic must not be altered by subsequent autonomous actions.
- **NFR-2 (Idempotency)**: The patch orchestrator (`patch_pulse.sh`) must be able to run multiple times without causing syntax corruption or duplicated lines.

## 6. Constraints & Dependencies
- Must align with **Architecture v3.0 (Ironclad)** manifest standards.
- Dependencies: Requires Node.js/Bun environment for Syntax Guard execution.

## 7. Acceptance Criteria (Checklist)
- [x] `pulse init` (User) completes without Gateway prompts.
- [x] `pulse init` (Org) saves a clean Org config and successfully pushes Gateway details to the specified User config.
- [x] Symlink `pulse.config.json` correctly points to the central `~/.config/pulse/` directory.
- [x] `pulse kw sync` successfully writes a clean array of keywords into the existing config file.
- [x] Syntax Guard (`bun build`) passes without errors.

---
*End of Document*