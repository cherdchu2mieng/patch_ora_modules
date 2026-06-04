<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# RFC Master Specification: RFC-20260604-PULSE-MULTI-PROJECT-CHB-V1

## 1. Document Control
- **Project**: pulse-cli
- **RFC ID**: RFC-20260604-PULSE-MULTI-PROJECT-CHB-V1
- **Priority**: P1
- **Requester**: Human
- **Approver**: Human (cherdchu2mieng)
- **Responsible Agent**: Gemi 🌊
- **Patch Workspace**: /home/a2it49072/ghq/github.com/cherdchu2mieng/patch_ora_modules
- **Target Repo**: itinfosv/pulse-cli
- **Structure**: ψ/writing/pulse-cli/RFC-20260604-PULSE-MULTI-PROJECT-CHB-V1/
- **Stability Impact**: Medium
- **Security Level**: Standard
- **Target Version**: v8.5.2
- **Status**: Open

## 2. Scope Consensus (The 3-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- ปรับปรุง `pulse-cli` ให้รองรับกรณีที่บอร์ดต้นทาง (ITB) และบอร์ดปลายทาง (AIB) มีเลขโปรเจกต์ (Project Number) ต่างกัน โดยการขยายโครงสร้าง Config และปรับปรุง Logic การสลับบริบทในคำสั่ง `chb`

### 2.2 Human Supplemental Input
- ปรับปรุงโครงสร้างส่วน `board` ใน Config ให้ระบุ `projectNumber` รายบอร์ดได้
- ปรับปรุงคำสั่ง `init` ให้รองรับการตั้งค่าบอร์ดแบบละเอียด

### 2.3 Information Gathering (Research)
- **IG-1 (Technical Baseline)**: ปัจจุบัน `chb` ใช้ `cfg.projectNumber` ตัวเดียวสำหรับทุกบอร์ด
- **IG-2 (Integration Points)**: กระทบไฟล์ `config.ts`, `chb.ts`, `init.ts` และการใช้งาน SDK `PulseContext`
- **IG-3 (Operational Constraints)**: ต้องรองรับ Config แบบเก่า (Backward Compatibility)

## 3. Change Request (CR) Portfolio
| CR ID | Module | Technical Objective | Detail File | Status |
| :--- | :--- | :--- | :--- | :--- |
| CR-001 | pulse-cli | Schema Expansion & Board Resolver | CR-001_detail.md | Pending |
| CR-002 | pulse-cli | CHB Context Switching Refactor | CR-002_detail.md | Pending |
| CR-003 | pulse-cli | Enhanced Init Flow for Multi-Board | CR-003_detail.md | Pending |

## 4. RFC-Level Summary (Post-Closure)
- **Total Duration**: ---
- **Total Token Cost**: ---
