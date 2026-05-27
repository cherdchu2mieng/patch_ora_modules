# Change Request Detail: CR-PULSE-ALIGN-001

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: add)
- **Target Branch**: feature/protocol-align-add
- **Worktree Required**: Yes - To isolate command logic changes.
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification
- **Affected Components**: 
    - `packages/cli/src/commands/add.ts`
    - `packages/cli/src/pulse.ts` (CLI argument parsing)
- **Logic Description**:
    1. **Pre-check**: แก้ไข `add.ts` ให้ทำการตรวจสอบไฟล์ `pulse.config.json` ใน Directory ปัจจุบัน (Current Working Directory)
    2. **Error Handling**: หากไม่พบไฟล์คอนฟิก ให้แสดงข้อความ `Run pulse init first.` และหยุดการทำงาน
    3. **Board-Specific Client**: 
        - อ่านค่าฟิลด์ `org` จากไฟล์คอนฟิก
        - หาก `org === "itinfosv"`, ตั้งค่า `Client` เริ่มต้นเป็น `Human`
        - หากไม่ใช่, ตั้งค่า `Client` เริ่มต้นเป็น `AI`
    4. **Status Enforcement**: บังคับให้ไอเทมใหม่มีสถานะ (`Status`) เป็น `New` เสมอ
    5. **Syntax Update**: ปรับปรุง `pulse.ts` ให้รองรับการรับค่า `pulse add "Title" "Body"` โดยที่ Body เป็นค่าเลือกได้ (Optional)
    6. **SDK Integration**: ใช้ `setFieldOnItem` เพื่อบันทึกค่าสถานะและ Client ลงบน GitHub Project

## 3. Impact Assessment
- **Integration Impact**: ตรวจสอบให้แน่ใจว่าการบังคับสถานะ 'New' ไม่ไปทับซ้อนกับตรรกะการตั้งค่า Priority ที่มีอยู่เดิม
- **Regression Risk**: ต่ำ - เป็นการปรับปรุงค่าเริ่มต้นและการตรวจสอบความถูกต้องของระบบ

## 4. Acceptance Criteria
- [ ] เมื่อรัน `pulse add` โดยไม่มีไฟล์คอนฟิก ระบบต้องแจ้งเตือนให้รัน `init`
- [ ] เมื่อสร้างงานใน Org `itinfosv`, ฟิลด์ Client บนบอร์ดต้องเป็น `Human` อัตโนมัติ
- [ ] เมื่อสร้างงานใน Org อื่นๆ, ฟิลด์ Client บนบอร์ดต้องเป็น `AI` อัตโนมัติ
- [ ] ไอเทมใหม่ทุกชิ้นต้องมีสถานะเป็น `New` บนบอร์ดบริหารจัดการ
- [ ] รองรับการส่ง Body ผ่านคำสั่งโดยไม่ต้องระบุ Flag `--body` (เช่น `pulse add "Title" "My Body content"`)

## 5. Post-Implementation Report
- **Status**: Verified / Sacred 🛡️
- **Completion Date**: 2026-05-25
- **Files Modified**:
    - `packages/cli/src/commands/add.ts`
    - `packages/cli/src/pulse.ts`
- **Development Duration**: ~45 min
- **Test Methodology**: 
    - Verified `pulse add` error when `pulse.config.json` is missing.
    - Verified automatic `Client: Human` assignment in `itinfosv` org.
    - Verified automatic `Client: AI` assignment in other orgs.
    - Verified mandatory `Status: New` enforcement.
    - Verified positional body support (`pulse add "Title" "Body"`).
- **Oracle Signature**: Gemi 🌊 (v8.4.0-cr001)

---
*Tested from human = Sacred* 🛡️

