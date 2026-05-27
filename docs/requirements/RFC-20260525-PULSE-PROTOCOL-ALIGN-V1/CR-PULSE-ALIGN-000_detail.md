# Change Request Detail: CR-PULSE-ALIGN-000

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: init)
- **Execution Skill**: build-patch
- **Status**: Verified 🛡️ (Tested from human = Sacred)

## 2. Technical Scope
- **Nature of Change**: Foundational Refactoring & Standardization
- **Affected Components**: 
    - `packages/cli/src/commands/init.ts` (Sequence & Discovery Logic)
    - `packages/cli/src/config.ts` (Interface & Context API)
- **Key Implementation Details**:
    1. **Upfront Identity Gathering**: Collected all identity markers (`githubUser`, `githubOrg`) at the start to eliminate redundant prompts.
    2. **Standard Prompt Sequence**:
        - `1. GitHub user`
        - `2. GitHub org`
        - `3. Gateway Oracle`
        - `4. Orchestrator Oracle`
        - `5. Initialize scope: [U]ser or [O]rg?`
        - `6. Project number`
    3. **Orchestrator Object**: Structured as `{ repo: string, oracle: string }`.
        - **Owner Rule**: The `repo` owner is always mapped to the `githubUser` for personal AI environments.
    4. **Automatic Board Mapping**:
        - `ITB`: Derives path from `{githubOrg}/pulse-oracle` (Master/Team domain).
        - `AIB`: Derives path from `{githubUser}/pulse-oracle` (AI Orchestrator domain).
    5. **Simplified Gateway**: Retained only core routing (`repo`, `oracle`), removing transient metadata (Client/Priority).
    6. **Smart Baseline Linking**: Implemented detection of existing master config files in `~/.config/pulse/` to anchor current repositories into an established fleet without re-scanning.

## 3. Impact Assessment
- **Reliability**: Ensures 100% consistent config structures across the fleet.
- **Efficiency**: Reduces `pulse init` friction for multi-repo environments via Smart Linking.
- **Traceability**: Provides the explicit `board` and `orchestrator` objects required for CR-004 (Direct Ingress).

## 4. Acceptance Criteria
- [x] Identity collection happens before scope selection.
- [x] Board (ITB/AIB) mapping follows organizational vs. personal domain standards.
- [x] Existing configs are detected and linked correctly.
- [x] Orchestrator repo owner is strictly pinned to the human `githubUser`.

## 5. Post-Implementation Report
- **Verified Date**: 2026-05-26
- **Methodology**: Verified via multi-repo initialization across `it49072-oracle` and `sky-oracle`.
- **Result**: **SACRED LOCKED** 🛡️🔒
