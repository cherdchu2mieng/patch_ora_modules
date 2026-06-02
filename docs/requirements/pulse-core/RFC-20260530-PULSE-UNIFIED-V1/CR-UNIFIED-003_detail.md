<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-UNIFIED-003

## 1. Metadata
- **CR ID**: CR-UNIFIED-003
- **Module**: pulse triage
- **Technical Objective**: Implement V1 Unified Governance Standard (Orchestrator Only)
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred) 🛡️🔒

## 2. Requirement Mapping (From FR-UNIFIED-TRIAGE-V1)
- ระบบคัดกรองงาน (Triage) เพื่อความสมบูรณ์ของข้อมูล
- บังคับใช้สิทธิ์ Orchestrator เท่านั้นผ่าน `enforceAuth()`
- ตรวจจับ Missing Metadata และ Stale Tasks

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 Authority Gate Integration
- **Target**: `packages/cli/src/commands/triage.ts`
- **Action**: แทรกฟังก์ชัน `enforceAuth()` ที่จุดเริ่มต้นของคำสั่งเพื่อหยุดการทำงานหากผู้ใช้ไม่มีสิทธิ์

### 3.2 Missing Metadata Logic
- **Target**: `packages/cli/src/commands/triage.ts`
- **Action**: ปรับปรุงลอจิกการกรองข้อมูลเพื่อระบุงานที่ฟิลด์ `Priority`, `Oracle`, หรือ `Client` เป็นค่าว่าง (`---`)

### 3.3 Stale Task Detection
- **Target**: `packages/cli/src/commands/triage.ts`
- **Action**: เพิ่มการคำนวณส่วนต่างของวันที่ (Last Updated vs Current Date) หากสถานะคือ `In Progress` และเกิน 7 วัน ให้แสดงเครื่องหมายแจ้งเตือน

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse tr` ปฏิเสธการทำงานหากผู้ใช้ไม่ใช่ Orchestrator
- [ ] แสดงรายการงานที่ขาด Priority/Oracle/Client อย่างถูกต้อง
- [ ] มีการระบุงานที่ "ค้างนาน" (Stale) ในผลลัพธ์
- [ ] Syntax Guard (`bun build`) ผ่านการตรวจสอบ

## 5. Post-Implementation Report
- **Files Modified**: TBD
- **Duration**: TBD
- **Test Methodology**: TBD
