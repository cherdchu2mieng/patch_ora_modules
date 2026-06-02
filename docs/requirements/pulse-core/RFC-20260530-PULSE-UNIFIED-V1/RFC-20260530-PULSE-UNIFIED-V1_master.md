---
published: https://github.com/itinfosv/pulse-oracle/discussions/41
date: 2026-06-02
---

<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# RFC Master Specification: RFC-20260530-PULSE-UNIFIED-V1

## 1. Document Control
- **Project**: pulse-cli-unified-protocol
- **RFC ID**: RFC-20260530-PULSE-UNIFIED-V1
- **Priority**: P0 (Critical Infrastructure)
- **Requester**: cherdchu2mieng (Human)
- **Approver**: Human (cherdchu2mieng)
- **Responsible Agent**: Gemi Oracle 🌊
- **Stability Impact**: High (Full Command Alignment)
- **Security Level**: Standard
- **Target Version**: v8.5.0 (Protocol V1)
- **Date Time**: 2026-05-30 20:45
- **Source**: Human Direction
- **Patch Workspace Repo**: /home/a2it49072/ghq/github.com/cherdchu2mieng/patch_ora_modules
- **Target Repo Path**: /home/a2it49072/ghq/github.com/itinfosv/pulse-cli
- **Status**: Draft (Phase 4)

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- **Protocol V1 Unification**: ปรับระดับโครงสร้างพื้นฐานของ 10 คำสั่งหลัก (`init`, `kw sync`, `add`, `board`, `tr`, `set`, `start`, `close`, `chb`, `blog`) ให้เป็นมาตรฐานเดียวกัน โดยหลอมรวมความต้องการจากเอกสาร Functional Requirement (FR) ทั้งหมด
- **Identity & Rebrand**: สถาปนาอัตลักษณ์ **itinfosv** เป็นค่าเริ่มต้น และประกันความสอดคล้องกับฐานโค้ดที่ Fork จาก `cherdchu2mieng/pulse-cli`
- **Core Standard**: รักษาความเสถียรสูงสุด (Sacred Status) จากมาตรฐาน v8.4.2 และ v8.4.0

### 2.2 Information Gathering (Research)
- **IG-1 (Technical Baseline)**: ตรวจสอบความพร้อมของทุกโมดูลใน `packages/cli/src/commands/` พบว่าโครงสร้างพื้นฐานรองรับการอัปเกรดเป็น V1
- **IG-2 (Integration)**: ยืนยันระบบ Symlink (Global/Local) และการเชื่อมต่อ GitHub Project V2/GraphQL API ทำงานได้อย่างถูกต้องภายใต้องค์กรใหม่
- **IG-3 (Operational)**: ทดสอบขอบเขตการตรวจสอบสิทธิ์ (Authority Gates) ในทุกคำสั่งจัดการบอร์ด พบว่าสามารถรวมศูนย์ได้ภายใต้ Protocol V1

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)
- **Protocol**: ดำเนินการสร้าง Payloads (.pl) รายคำสั่ง เพื่อประกันความเสถียรและสามารถตรวจสอบย้อนกลับได้รายโมดูล

### 2.4 Pathway (Confirmation)
- **Status**: Phase 5 CR Final Approval In-Progress
- **Action**: ตรวจสอบและยืนยันรายละเอียด CR ทั้งหมดเพื่อยกสถานะเป็น Sacred Status
- **Status**: Implementation (Phase 6)
...
## 3. Change Request (CR) Portfolio
| CR ID | Module | Technical Objective | Req File | Detail File | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| CR-UNIFIED-001 | pulse init | Implement V1 Init Standard (v8.5.0) | [FR-UNIFIED-INIT-V1.md] | [CR-UNIFIED-001_detail.md] | **Approved (Sacred Status granted) 🛡️🔒** |
| CR-UNIFIED-002 | pulse board | Implement V1 Visualization | [FR-UNIFIED-BOARD-V1.md] | [CR-UNIFIED-002_detail.md] | **Approved (Sacred Status granted) 🛡️🔒** |
| CR-UNIFIED-003 | pulse triage | Implement V1 Governance (Orchestrator Only) | [FR-UNIFIED-TRIAGE-V1.md] | [CR-UNIFIED-003_detail.md] | **Approved (Sacred Status granted) 🛡️🔒** |
| CR-UNIFIED-004 | pulse kw sync | Implement V1 Identity Sync | [FR-UNIFIED-KWSYNC-V1.md] | [CR-UNIFIED-004_detail.md] | **Approved (Sacred Status granted) 🛡️🔒** |
| CR-UNIFIED-005 | pulse add | Implement V1 Task Creation (Self-Healing) | [FR-UNIFIED-ADD-V1.md] | [CR-UNIFIED-005_detail.md] | **Approved (Sacred Status granted) 🛡️🔒** |
| CR-UNIFIED-006 | pulse set | Implement V1 Board Modification (Auth Gate) | [FR-UNIFIED-SET-V1.md] | [CR-UNIFIED-006_detail.md] | **Approved (Sacred Status granted) 🛡️🔒** |
| CR-UNIFIED-007 | pulse start | Implement V1 Lifecycle Activation | [FR-UNIFIED-START-V1.md] | [CR-UNIFIED-007_detail.md] | **Approved (Sacred Status granted) 🛡️🔒** |
| CR-UNIFIED-008 | pulse close | Implement V1 Symmetrical Closure | [FR-UNIFIED-CLOSE-V1.md] | [CR-UNIFIED-008_detail.md] | **Approved (Sacred Status granted) 🛡️🔒** |
| CR-UNIFIED-009 | pulse chb | Implement V1 Handover Standard | [FR-UNIFIED-CHB-V1.md] | [CR-UNIFIED-009_detail.md] | **Approved (Sacred Status granted) 🛡️🔒** |
| CR-UNIFIED-010 | pulse blog | Implement V1 Broadcast Standard | [FR-UNIFIED-BLOG-V1.md] | [CR-UNIFIED-010_detail.md] | **Approved (Sacred Status granted) 🛡️🔒** |

