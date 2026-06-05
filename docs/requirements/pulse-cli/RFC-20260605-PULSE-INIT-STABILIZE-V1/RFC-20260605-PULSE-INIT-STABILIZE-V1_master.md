<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# RFC Master Specification: RFC-20260605-PULSE-INIT-STABILIZE-V1

## 1. Document Control
- **Project**: pulse-cli
- **RFC ID**: RFC-20260605-PULSE-INIT-STABILIZE-V1
- **Priority**: P0 (Critical)
- **Requester**: Human
- **Approver**: Human (cherdchu2mieng)
- **Responsible Agent**: Gemi 🌊
- **Patch Workspace**: /home/a2it49072/ghq/github.com/cherdchu2mieng/patch_ora_modules
- **Target Repo**: itinfosv/pulse-cli
- **Structure**: ψ/writing/pulse-cli/RFC-20260605-PULSE-INIT-STABILIZE-V1/
- **Stability Impact**: High
- **Security Level**: Standard
- **Target Version**: v8.5.3
- **Status**: Closed (Implementation Verified)

## 2. Scope Consensus (The 3-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
ปรับปรุงระบบการตั้งค่า (Initialization) ของ Pulse CLI ให้มีความเป็นมิตรต่อผู้ใช้งานมากขึ้น โดยเพิ่มการเลือกขอบเขตการทำงาน (User vs Org) และระบบ Default-on-Enter พร้อมทั้งแก้ไขปัญหาทางเทคนิค (Bug) ในการประกาศข่าว (Blog) และการจัดการบอร์ด (CHB) ที่เกิดจากความไม่เข้ากันของประเภทข้อมูลในคอนฟิก

### 2.2 Human Supplemental Input
- ปรับปรุง `pulse init` ให้สร้าง `pulse.config.json` ได้ง่ายขึ้น
- ใช้ค่า Default ใน `[ ]` เมื่อกด Enter
- แก้ไขปัญหา TypeError ใน `pulse blog` (includes is not a function)
- ทำให้การดึงข้อมูล Board รองรับทั้ง String และ Object

### 2.3 Information Gathering (Research)
- **IG-1 (Technical Baseline)**: `blog.ts` มีการเรียกใช้ `cfg.board.ITB` โดยสมมติว่าเป็น String เสมอ ซึ่งขัดแย้งกับความเป็นจริงที่อาจเป็น Object
- **IG-2 (Operational Constraints)**: ลอจิกใน `init.ts` ปัจจุบันยังไม่ได้ทำการ Map ค่า `org` และ `projectNumber` ตาม Scope (U/O) ที่ผู้ใช้เลือกอย่างชัดเจน
- **IG-3 (Governance)**: ต้องรักษามาตรฐานการสร้าง Bidirectional Link ใน `chb.ts` ให้ทำงานได้ถูกต้องกับโครงสร้างข้อมูลใหม่

## 3. Functional Requirements (FR) Portfolio
| FR ID | Title | Detail File | Status |
| :--- | :--- | :--- | :--- |
| FR-1 | Simplified Pulse Init Protocol | FR-1.md | Confirmed |
| FR-2 | Board-Aware Config Compatibility Fix | FR-2.md | Confirmed |

## 4. Change Request (CR) Portfolio
| CR ID | Module | Technical Objective | Detail File | Status |
| :--- | :--- | :--- | :--- | :--- |
| CR-001 | commands/init.ts | Simplified Init Flow & Context Mapping | CR-001_detail.md | Confirmed |
| CR-002 | config.ts, blog.ts | Board Data Type Safety & TypeError Fix | CR-002_detail.md | Confirmed |
| CR-003 | commands/chb.ts | Board Context Alignment (chb fix) | CR-003_detail.md | Confirmed |

## 5. Risk & Mitigation
- **Risk**: การเปลี่ยนโครงสร้างคอนฟิกอาจกระทบต่อ Oracle รุ่นเก่าที่ยังใช้ค่า String
- **Mitigation**: เพิ่ม Helper ใน `config.ts` ที่ทำหน้าที่ Normalize ข้อมูลให้รองรับทั้ง 2 รูปแบบ (String/Object) ก่อนส่งให้ฟังก์ชันใช้งาน

## 6. RFC-Level Summary (Post-Closure)
- **Total Duration**: ~3 hours (including Hotfix iterations)
- **Closure Status**: All CRs (CR-001, CR-002, CR-003, CR-005) successfully implemented, verified by Human, and locked as Sacred. Code delivered to `itinfosv/pulse-cli` under tag `v8.5.4`.
- **Note**: This RFC successfully stabilized the init UX and decoupled hardcoded string constraints from board configurations.
