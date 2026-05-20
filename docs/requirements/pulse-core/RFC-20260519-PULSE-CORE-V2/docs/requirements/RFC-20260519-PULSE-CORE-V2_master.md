# RFC Master Specification: RFC-20260519-PULSE-CORE-V2

## 1. Document Control
- **Project**: pulse-core
- **RFC ID**: RFC-20260519-PULSE-CORE-V2
- **Priority**: P1
- **Requester**: Human
- **Approver**: Human (cherdchu2mieng)
- **Responsible Agent**: Gemi Oracle 🌊
- **Stability Impact**: High
- **Security Level**: Standard
- **Target Version**: v8.2.2
- **Status**: Open

## 2. Scope Consensus (The 3-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- Stabilize and enhance core Pulse CLI commands (`board`, `start`, `go`, `close`, `tr`).
- Implement a local-first execution model with automatic bidirectional synchronization to the Master Board.
- Establish a secure authorization gate for management commands (Triage).

### 2.2 Human Supplemental Input
- **Anchor Logic**: Use the GitHub Issue Body to store cross-links (`Parent: org/repo#ID`) instead of external mapping files.
- **pulse start**: A compound command calling `pulse task` (Pull & Anchor) followed by `pulse go` (Status: In Progress).
- **ID Management**: Explicitly handle the difference between Master Board Item IDs and Local Issue IDs.
- **Centralized Authority**: Restrict `pulse tr` to the designated Orchestrator only, consistent with `pulse set`.

### 2.3 Information Gathering (Research)
- **IG-1 (Technical Baseline)**: Current logic exists in `cmd_task@v8.2.1.pch` and `cmd_go@v8.2.1.pch` using regex-based anchoring. `pulse-cli` source is located in `Pulse-Oracle/pulse-cli`.
- **IG-2 (Integration Points)**: Depends on `sdk/github.ts` for GraphQL API interactions and `config.ts` for orchestrator identity.
- **IG-3 (Operational Constraints)**: Must handle UTF-8/Thai characters and responsive terminal table formatting. Must prevent duplicate worktree creation.

## 3. Change Request (CR) Portfolio
| CR ID | Module | Technical Objective | Detail File | Status |
| :--- | :--- | :--- | :--- | :--- |
| CR-PULSE-CORE-001 | pulse-cli | Enhanced Visualization (`pulse board`) | CR-PULSE-CORE-001_detail.md | Pending |
| CR-PULSE-CORE-002 | pulse-cli | Compound Lifecycle Start (`pulse start`/`task`) | CR-PULSE-CORE-002_detail.md | Pending |
| CR-PULSE-CORE-003 | pulse-cli | Bidirectional Sync & Closure (`pulse go`/`close`) | CR-PULSE-CORE-003_detail.md | Pending |
| CR-PULSE-CORE-004 | pulse-cli | Governance & Auth Triage (`pulse tr`) | CR-PULSE-CORE-004_detail.md | Pending |

## 4. RFC-Level Summary (Post-Closure)
- **Total Duration**: TBD
- **Total Token Cost**: TBD
