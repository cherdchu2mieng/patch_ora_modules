---
published: https://github.com/itinfosv/pulse-oracle/discussions/39
date: 2026-05-28
---

<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# RFC Master Specification: RFC-20260528-ITINFOSV-REBRAND-V1

## 1. Document Control
- **Project**: itinfosv-pulse-cli-branding
- **RFC ID**: RFC-20260528-ITINFOSV-REBRAND-V1
- **Priority**: P1 (Important)
- **Requester**: cherdchu2mieng (Human)
- **Approver**: Human (cherdchu2mieng)
- **Responsible Agent**: Gemi Oracle 🌊
- **Stability Impact**: Low
- **Security Level**: Standard
- **Target Version**: v8.5.0
- **Date Time**: 2026-05-28 10:45
- **Source**: Human Direction
- **Patch Workspace Repo**: /home/a2it49072/ghq/github.com/cherdchu2mieng/patch_ora_modules
- **Target Repo Path**: /home/a2it49072/ghq/github.com/itinfosv/pulse-cli
- **Status**: Closed (Implementation Complete) 🏁

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- ปรับปรุงการอ้างอิงอัตลักษณ์ (Branding) ใน Repository `itinfosv/pulse-cli` ให้ถูกต้องตามเจ้าของใหม่ (itinfosv) แทนที่ Pulse-Oracle
- ตรวจสอบความสมบูรณ์ของลิงก์และคำสั่งที่เกี่ยวข้องในไฟล์ระบบและเอกสาร

### 2.2 Human Supplemental Input
- **Consistency**: ต้องไม่กระทบต่อตรรกะการทำงานหลักของโปรแกรม
- **Sacred Preservation**: ต้องรักษาประวัติการ Patch (Manifest Headers) ของเวอร์ชัน v8.4.2 เดิมไว้

### 2.3 Information Gathering (Research)
- **IG-1 (Technical Baseline)**: พบการอ้างอิงใน `package.json`, `README.md` และ `.github/workflows/inbox-auto-add.yml`
- **IG-2 (Integration)**: Workflow ยังคงใช้ Project Board ของ `laris-co` (ซึ่งถูกต้องแล้ว) แต่ต้องตรวจสอบชื่อ Organization ในการแจ้งเตือน `maw hey`
- **IG-3 (Operational)**: การแก้ไขจะช่วยให้ `ghq` และเครื่องมือ Git อื่นๆ ระบุแหล่งที่มา (Origin) ได้ถูกต้อง

### 2.4 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (v2.7)
- **Protocol**: ดำเนินการผ่านระบบ Payloads เพื่อความเสถียรและสามารถตรวจสอบย้อนกลับได้

---

#### **3.3 Sub-process: Local Symlink Alignment**
ปรับปรุงลิงก์ในระบบพัฒนา (Local Dev Links) ให้ชี้ไปยัง Repository ใหม่

- **Layer 1: Requirement Mapping**
    - แก้ไข Symlinks ใน `.bun/install/global/node_modules/` ให้ชี้ไปยัง `itinfosv/pulse-cli`
- **Layer 2: Information Gathering**
    - **IG-1 (Technical)**: พบลิงก์ `pulse-oracle` และ `pulse-oracle-cli` ชี้ไปยัง `Pulse-Oracle/pulse-cli`
- **Layer 3: Implementation Governance (Layer 4)**
    - **Execution Skill**: `N` (Manual Shell Commands)
- **Layer 4: Pathway**
    - **Confirm**: **`brfc-Phase 3.3 confirm`**

## 3. Change Request (CR) Portfolio
| CR ID | Module | Technical Objective | Detail File | Status |
| :--- | :--- | :--- | :--- | :--- |
| CR-ITINFOSV-001 | Metadata | Update package.json & GitHub Workflows | [CR-ITINFOSV-001_detail.md] | **Approved (Sacred Status granted)** |
| CR-ITINFOSV-002 | Documentation | Update README.md clone & path references | [CR-ITINFOSV-002_detail.md] | **Approved (Sacred Status granted)** |
| CR-ITINFOSV-003 | Installation | Realign local development symlinks | [CR-ITINFOSV-003_detail.md] | **Approved (Sacred Status granted)** |

## 4. RFC-Level Summary (Post-Closure)
- **Actual Duration**: TBD
- **Actual Token Cost**: TBD
tatus**: All CRs successfully implemented, verified, and locked as Sacred. Code and documentation now accurately reflect the `itinfosv/pulse-cli` identity. Local development symlinks have been permanently realigned.
- **Note**: This RFC successfully completed the migration of the core Pulse engine to the IT Board organization, establishing the baseline for future enterprise-grade enhancements.
