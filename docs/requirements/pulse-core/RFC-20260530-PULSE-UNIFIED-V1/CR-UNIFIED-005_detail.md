<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-UNIFIED-005

## 1. Metadata
- **CR ID**: CR-UNIFIED-005
- **Module**: pulse add
- **Technical Objective**: Implement V1 Unified Task Creation Standard (Self-Healing & Smart Routing)
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred) 🛡️🔒

## 2. Requirement Mapping (From FR-UNIFIED-ADD-V1)
- รวมความสามารถ Self-Healing และ Smart Routing เข้าสู่มาตรฐาน V1
- บังคับสถานะเริ่มต้นเป็น `New` และกำหนด Target ไปที่ `itinfosv/pulse-oracle`
- รองรับ Positional Body Argument

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 Self-Healing Repository Logic
- **Target**: `packages/cli/src/commands/add.ts`
- **Action**: แทรกโค้ดตรวจสอบการมีอยู่ของ Repository `pulse-oracle` หากไม่พบ ให้เรียกใช้ `gh repo create --public` อัตโนมัติ

### 3.2 Positional Argument Support
- **Target**: `packages/cli/src/commands/add.ts`
- **Action**: ปรับปรุงการรับค่าจาก Command line ให้ Argument ที่ 2 ถูกกำหนดเป็น Body ของ Issue โดยอัตโนมัติหากไม่ได้ใช้ Flag `--body`

### 3.3 Default Status & Organization
- **Target**: `packages/cli/src/commands/add.ts`
- **Action**: Hardcode ค่าเริ่มต้นของสถานะเป็น `New` และ Organization เป็น `itinfosv` (หากไม่มีการระบุเป็นอย่างอื่นในคอนฟิก)

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse add` แสดง Banner V1 (v8.5.0)
- [ ] สร้าง Repository `pulse-oracle` ให้อัตโนมัติหากยังไม่มี
- [ ] งานที่สร้างใหม่มีสถานะ `New` เสมอ
- [ ] สามารถใส่รายละเอียดงานต่อท้ายชื่อหัวข้อได้ทันที
- [ ] Syntax Guard (`bun build`) ผ่านการตรวจสอบ

## 5. Post-Implementation Report
- **Files Modified**: TBD
- **Duration**: TBD
- **Test Methodology**: TBD
