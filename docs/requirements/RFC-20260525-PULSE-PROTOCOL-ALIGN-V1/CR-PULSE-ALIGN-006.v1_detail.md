<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-PULSE-ALIGN-006.v1

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: blog)
- **Execution Skill**: build-patch
- **Status**: Approved (Tested from human = Sacred)

## 2. Technical Scope
- **Nature of Change**: Orchestrator Broadcast Enhancement (Replacing Gateway Task)
- **Affected Components**: 
    - `packages/cli/src/commands/blog.ts`
- **Key Implementation Details**:
    1. **Orchestrator Authority Gate**: Add `enforceOrchestrator()` check to the command. Only identified Orchestrators can publish to the team repository.
    2. **Dynamic Team Routing**:
        - If the actor is an Orchestrator, default the target repository to `itinfosv/pulse-oracle` for discussions.
        - Ensure category defaults to `Announcements` or `Show and tell` from config.
    3. **Provenance & Sync Persistence**: Maintain the existing logic that appends Git provenance (commit hash, session ID) and updates the source file's frontmatter with the published URL.
    4. **Decommission Task Logic**: Remove dependencies on the previous `pulse task` command within the CLI routing if applicable.

## 3. Impact Assessment
- **Communication Efficiency**: Centralizes team-wide announcements through a single, high-authority channel.
- **Security**: Prevents unauthorized automated posts to the team's public-facing repository.
- **Traceability**: Enhances the link between local development sessions and global team discussions.

## 4. Acceptance Criteria
- [ ] Command `pulse blog` is blocked for non-Orchestrator identities.
- [ ] Successful broadcast publishes to `itinfosv/pulse-oracle`.
- [ ] Source file's frontmatter is correctly updated with the new discussion URL.
- [ ] Provenance block is correctly appended to the discussion body.

## 5. Post-Implementation Report
*To be filled after implementation.*

---
*Refined from CR-PULSE-ALIGN-006 (Gateway Task)* 🛡️🔄
