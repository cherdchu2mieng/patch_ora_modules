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
- **Date Time**: 2026-05-25 11:30 (Initial) | 2026-05-26 16:15 (Sacred Refined)
- **Source**: Human Direction (cherdchu2mieng) & Operational Mandates
- **Patch Workspace Repo**: /home/a2it49072/ghq/github.com/cherdchu2mieng/patch_ora_modules
- **Target Repo Path**: /home/a2it49072/ghq/github.com/Pulse-Oracle/pulse-cli
- **Status**: Open (Phase 4 Master Drafting - Comprehensive Review)

## 2. Scope Consensus (The 3-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- ปรับปรุง Pulse CLI ให้รองรับโปรโตคอลการสื่อสารสองทิศทาง (Bidirectional) ระหว่าง ITB และ AIB โดยใช้การตรวจสอบสิทธิ์แบบอิงพื้นที่ทำงาน (Workspace-Based Authority) เพื่อความปลอดภัยและความเสถียรสูงสุด

### 2.2 Human Supplemental Input
- **Identity Enforcement**: ต้องระบุตัวตนจากชื่อโฟลเดอร์ Workspace และต้องตรงกับฟิลด์ Oracle ในบอร์ดถึงจะอนุญาตให้รันคำสั่งได้
- **Board Mapping**: กำหนด ITB เป็นบอร์ดทีม (itinfosv) และ AIB เป็นบอร์ดส่วนตัวของ Oracle (cherdchu2mieng)
- **Cycle Closure**: การกลับสู่วงจรปิดงาน (Return/Task) ต้องอัปเดตสถานะข้ามบอร์ดได้ถูกต้องแม่นยำผ่าน Anchor

### 2.3 Information Gathering (Research)
- **IG-1 (Technical Baseline)**: ตรวจสอบโมดูล `init.ts`, `add.ts`, `set.ts`, `chb.ts`, `task.ts`, และ `close.ts` พบความพร้อมในการปรับปรุงโครงสร้าง
- **IG-2 (Integration Points)**: ใช้ GitHub Project V2 SDK ในการซิงค์ข้อมูลผ่าน GraphQL และ REST API (gh CLI)
- **IG-3 (Operational Constraints)**: การทำงานต้องแยกกันระหว่าง "Brain" (gemi-oracle) และ "Patch Workspace" (patch_ora_modules) อย่างเคร่งครัด

## 3. Change Request (CR) Portfolio
| CR ID | Module | Technical Objective | Detail File | Status |
| :--- | :--- | :--- | :--- | :--- |
| CR-PULSE-ALIGN-000 | System Init | Standardized Init & Identity Architecture | [CR-PULSE-ALIGN-000_detail.md] | **SACRED 🛡️🔒** |
| CR-PULSE-ALIGN-001 | Command: add | Board-specific defaults & mandatory 'New' status | [CR-PULSE-ALIGN-001_detail.md] | **SACRED 🛡️🔒** |
| CR-PULSE-ALIGN-002 | Command: board/tr | 10-col Board & Triage authority gates | [CR-PULSE-ALIGN-002_detail.md] | **SACRED 🛡️🔒** |
| CR-PULSE-ALIGN-003 | Command: set/start | Authority enforcement & auto-client updates | [CR-PULSE-ALIGN-003_detail.md] | **SACRED BLUEPRINT 🛡️** |
| CR-PULSE-ALIGN-004 | Command: chb | Bidirectional Sync (Ingress & Return Flow) | [CR-PULSE-ALIGN-004_detail.md] | **SACRED 🛡️🔒** |
| CR-PULSE-ALIGN-006 | Command: task | Gateway Cycle Closure & Broadcast logic | [CR-PULSE-ALIGN-006_detail.md] | **SACRED BLUEPRINT 🛡️** |
| CR-PULSE-ALIGN-007 | Command: close | Context-aware closure (Closed vs Done) | [CR-PULSE-ALIGN-007_detail.md] | **SACRED BLUEPRINT 🛡️** |

## 4. RFC-Level Summary (Post-Closure)
- **Phase 1-5 Status**: All Change Requests have been refined, audited, and confirmed as **Tested from human = Sacred**.
- **Current State**: The full bidirectional protocol is now locked in main memory.
- **Next Step**: Proceed to Phase 6 implementation for pending modules.
