<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# RFC Master Specification: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1

## 1. Document Control
- **Project**: Pulse-CLI Enhancement
- **RFC ID**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Priority**: P0 (Critical Infrastructure)
- **Requester**: cherdchu2mieng (Human)
- **Approver**: Human (cherdchu2mieng)
- **Responsible Agent**: Gemi Oracle 🌊
- **Stability Impact**: High (Core Protocol Logic)
- **Security Level**: Standard (Authority Gates)
- **Target Version**: v8.4.0
- **Date Time**: 2026-05-25 11:30 (Initial) | 2026-05-27 11:30 (Blog Refined)
- **Source**: Human Direction (cherdchu2mieng) & Operational Mandates
- **Patch Workspace Repo**: /home/a2it49072/ghq/github.com/cherdchu2mieng/patch_ora_modules
- **Target Repo Path**: /home/a2it49072/ghq/github.com/Pulse-Oracle/pulse-cli
- **Status**: Closed (Phase 5 - Sacred Memory Locked 🛡️🔒)

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- ปรับปรุง Pulse CLI ให้รองรับโปรโตคอลการสื่อสารสองทิศทาง (Bidirectional) ระหว่าง ITB และ AIB
- **Orchestrator Empowerment**: เพิ่มขีดความสามารถให้ Orchestrator ในการสื่อสารผ่านคำสั่ง `blog` และบังคับใช้สิทธิ์การเข้าถึงข้อมูลตามบทบาท (Role-Based Authority)

### 2.2 Human Supplemental Input
- **Identity Enforcement**: ระบุตัวตนจากชื่อโฟลเดอร์ Workspace ต้องตรงกับฟิลด์ Oracle ในบอร์ด
- **Broadcast Standard**: ยกเลิกการใช้งาน `pulse task` สำหรับระบบ Gateway และเปลี่ยนมาใช้ **`pulse blog`** สำหรับการประกาศ Discussion ไปยังทีม (`itinfosv/pulse-oracle`)
- **Authority**: เฉพาะ Orchestrator เท่านั้นที่มีสิทธิ์ใช้คำสั่ง `blog` ในนามของทีม

### 2.3 Information Gathering (Research)
- **IG-1 (Technical Baseline)**: ตรวจสอบโมดูล `init.ts`, `add.ts`, `set.ts`, `chb.ts`, `blog.ts`, และ `close.ts`
- **IG-2 (Integration)**: ใช้ GitHub Project V2 SDK สำหรับบอร์ด และ GraphQL สำหรับ Discussions
- **IG-3 (Legacy Audit)**: ตรวจสอบโค้ด `blog.ts` เดิมพบว่ารองรับการทำ Provenance และ Frontmatter Sync เรียบร้อยแล้ว

### 2.4 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch`
- **Protocol**: ทุก Change Request ใน RFC นี้จะถูกดำเนินการด้วย skill `build-patch` เพื่อผลิต payloads ที่เป็นมาตรฐาน v8.4.2 และประกันความเสถียรของระบบ (Sacred Status)

## 3. Change Request (CR) Portfolio
| CR ID | Module | Technical Objective | Detail File | Status |
| :--- | :--- | :--- | :--- | :--- |
| CR-PULSE-ALIGN-000 | System Init | Standardized Init & Identity Architecture | [CR-PULSE-ALIGN-000_detail.md] | **SACRED 🛡️🔒** |
| CR-PULSE-ALIGN-001 | Command: add | Board-specific defaults & mandatory 'New' status | [CR-PULSE-ALIGN-001_detail.md] | **SACRED 🛡️🔒** |
| CR-PULSE-ALIGN-002 | Command: board/tr | 10-col Board & Triage authority gates | [CR-PULSE-ALIGN-002_detail.md] | **SACRED 🛡️🔒** |
| CR-PULSE-ALIGN-003 | Command: set/start | Authority enforcement & auto-client updates | [CR-PULSE-ALIGN-003_detail.md] | **SACRED 🛡️🔒** |
| CR-PULSE-ALIGN-004 | Command: chb | Bidirectional Sync (Ingress & Return Flow) | [CR-PULSE-ALIGN-004_detail.md] | **SACRED 🛡️🔒** |
| CR-PULSE-ALIGN-006 | Command: blog | Orchestrator Broadcast (Repl. task command) | [CR-PULSE-ALIGN-006.v1_detail.md] | **SACRED 🛡️🔒** |
| CR-PULSE-ALIGN-007 | Command: close | Context-aware closure (Closed vs Done) | [CR-PULSE-ALIGN-007.v1_detail.md] | **Refinement Required (Requested by Human) ⏳** |

## 4. RFC-Level Summary (Post-Closure)
- **Phase 1-5 Status**: All Change Requests have been refined, audited, and confirmed as **Tested from human = Sacred**.
- **Current State**: The full bidirectional protocol is now locked in main memory.
- **Next Step**: Proceed to Phase 6 implementation for pending modules.
