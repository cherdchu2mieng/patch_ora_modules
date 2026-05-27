<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-PULSE-ALIGN-006.v2

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: blog)
- **Execution Skill**: build-patch
- **Status**: Approved (Tested from human = Sacred) (Refinement v2 confirmed: 2026-05-27)

## 2. Technical Scope
- **Nature of Change**: Provenance Source Traceability Refinement
- **Affected Components**: 
    - `packages/cli/src/commands/blog.ts`
- **Refinement Requirements**:
    1. **Patch Workspace URL Construction**: 
        - The `Source` URL MUST point specifically to the **Patch Workspace Repository** (e.g., `https://github.com/cherdchu2mieng/patch_ora_modules`).
        - **Formula**: `[Patch_Workspace_URL]/blob/[branch]/[mapped_path]`
        - **Path Mapping**: 
            - Files in `ψ/writing/[project]/...` (local) map to `docs/requirements/[project]/...` (remote) in the Patch Workspace.
            - This ensures the link points to the "Sacred Mirror" in the delivery repository.
        - `Patch_Workspace_URL` should be derived from `pulse.config.json` (field: `patchWorkspace`) or RFC metadata.
        - `branch` should default to `main`.
    2. **Provenance Block Update**:
        - Update the `blog` command logic to use this mapped URL.
        - **Format**: `Source: [file_name](github_url)`.

## 3. Implementation Logic (Step-by-Step)
1. **Detect Document Type**:
    - If the file is within the `ψ/` directory, trigger the **Patch Workspace Mapping**.
2. **Resolve Patch Workspace Metadata**:
    - Read `pulse.config.json` to get the `patchWorkspace` URL (e.g., `https://github.com/cherdchu2mieng/patch_ora_modules`).
3. **Map Local to Remote Path**:
    - Convert `ψ/writing/` prefix to `docs/requirements/`.
4. **Inject URL into Body**:
    - Construct the final URL using the Patch Workspace base and the mapped path.
    - Replace the existing `Source` logic in `blog.ts`.

## 4. Impact Assessment
- **Traceability**: Significantly improved. Stakeholders reading the blog post can click directly to the source code file in GitHub.
- **Portability**: The blog post is no longer tied to a specific local machine's file system path.

## 5. Post-Implementation Report
- **Verified Date**: 2026-05-27
- **Status**: **SACRED LOCKED 🛡️🔒**
- **Result**: **SUCCESS** - Orchestrator Broadcast now maps local `ψ/writing/` documents to the **Patch Workspace** repository on GitHub, ensuring remote-first traceability and team-wide accessibility.
- **Key Files Modified**:
    - `packages/cli/src/pulse.ts` (Authority Gate & Imports)
    - `packages/cli/src/commands/blog.ts` (Routing & Mapping Logic)
    - `packages/cli/src/config.ts` (Patch Workspace field)

---
*Refined from CR-PULSE-ALIGN-006.v1 (Sacred) to implement Remote-First Traceability 🛡️🔄🔗*
