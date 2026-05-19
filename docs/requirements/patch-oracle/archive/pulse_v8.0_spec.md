# 🌊 Pulse v8.0: The Seamless Orchestration Lifecycle
**Status**: DRAFT | **Target**: pulse-cli

## 🎯 Architectural Vision
Transform Pulse from a simple "task recorder" into a **Context-Preserving Orchestration System**. Every task must have a clear origin, and state changes in local repositories must seamlessly synchronize back to the Master Board ("Local-First, Master-Follow").

---

## 1. pulse add (The Creator)
**Goal**: Create tasks on the Master Board with strict Orchestrator authority.

- **1.1 Default Behavior (No Oracle Specified)**
  - Creates an issue in pulse-oracle.
  - Fields are unassigned. Requires later refinement via pulse set.
- **1.2 Self-Assignment Express Lane (--oracle <own-name>)**
  - Creates an issue in pulse-oracle.
  - **Auto-Assignments**: Oracle = <own-name>, Priority = P0, Client = Self-Direct.
- **1.3 Restricted Delegation (--oracle <other-name>)**
  - Creates an issue in pulse-oracle.
  - **Action**: Denies assignment (leaves Oracle field blank) if the runner is not the Orchestrator. Warns the user.

## 2. pulse task <master_item#> (The Sync Linker)
**Goal**: Pull an assigned task from the Master Board into the local repository.

- **Pre-conditions**:
  1. Must explicitly provide the Master Item ID.
  2. The Master Item must be assigned to the oracle running the command.
  3. A cross-link must not already exist in the local repo.
- **Action**:
  - Fetches details from the Master Board.
  - Creates a new Issue in the local repository.
  - Establishes a bidirectional **Cross-Link** (e.g., Parent: cherdchu2mieng/pulse-oracle#ID) in the issue body.

## 3. pulse go <local_item#> (The Activator)
**Goal**: Transition task state to "In Progress" with bidirectional sync.

- **Phase 1 (Local)**: Changes local issue status to "In Progress".
- **Phase 2 (Master Sync)**: 
  - Scans local issue body for a Master Board Cross-Link.
  - If found, automatically updates the corresponding Master Item's status to "In Progress".

## 4. pulse start <master_item#> (The Combo)
**Goal**: Rapid task ingestion and activation.

- **Action**: A pipeline command executing pulse task <master_item#> immediately followed by pulse go <new_local_item#>.
- **Result**: Pulls the task, creates local issue, cross-links it, and sets both local and master statuses to "In Progress" in one fluid motion.

## 5. pulse close <local_item#> (The Coordinated Closure)
**Goal**: Complete tasks locally and automatically resolve them globally.

- **Phase 1 (Local)**: Closes the local issue and sets local board status to "Done".
- **Phase 2 (Master Sync)**:
  - Scans for Cross-Link.
  - If found, automatically closes the Parent Issue on the Master Board and sets the Master Item status to "Done".

## 6. pulse scan (The Assignment Discovery)
**Goal**: Identify assigned tasks that haven't been pulled locally.

- **Action**: Scans the Master Board for issues assigned to the current oracle that lack a known Cross-Link.
- **Output**: Alerts the oracle to pending tasks (e.g., "Found 2 pending tasks. Run pulse task <ID> to pull them.").

## 7. pulse tr (The Connectivity Audit)
**Goal**: Detect synchronization failures and orphaned tasks.

- **Action**: Audits local issues.
- **Checks**:
  - Identifies orphaned tasks (created locally but not linked to the Master Board).
  - Detects state desynchronization (e.g., Local is "Done", but Master is "In Progress").
- **Output**: Actionable alerts for the oracle to synchronize states.

---
**Oracle Signature**: Gemi 🌊 (Deep Blue Horizon)
*"We synchronize the fleet not by force, but by design."*
