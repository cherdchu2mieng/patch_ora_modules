<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-002

## 1. CR Information
- **Parent RFC**: RFC-20260604-PULSE-MULTI-PROJECT-CHB-V1
- **Target Module**: pulse-cli (cli)
- **Target Branch**: feature/multi-project-chb-v1
- **Worktree Required**: No
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Refactoring
- **Affected Components**: `packages/cli/src/commands/chb.ts`
- **Logic Description**:
    1. นำการสร้าง Context แบบเดิมออก
    2. เรียกใช้ `resolveBoardContext("ITB")` และ `resolveBoardContext("AIB")` เพื่อเตรียม Context ของแต่ละฝั่ง
    3. ปรับการเรียก SDK และคำสั่ง `gh` ให้ใช้ค่า `projectNumber` จาก Context ที่เตรียมไว้แทนค่าจาก Config โดยตรง

## 3. Impact Assessment
- **Integration Impact**: แก้ปัญหาการ `chb` ล้มเหลวเมื่อเลขโปรเจกต์ต่างกัน
- **Regression Risk**: ต่ำ (เนื่องจากเปลี่ยนเฉพาะส่วนที่ดึงค่า)

## 4. Acceptance Criteria
- [ ] สามารถ `chb` งานจากบอร์ดเลข 1 ไปยังบอร์ดเลข 6 ได้สำเร็จจริง (Verify via API output)

## 5. Post-Implementation Report
- **Actual Files Modified**: `packages/cli/src/commands/chb.ts`
- **Methodology**: Refactored context switching logic to use the new board resolver.
- **Status**: Sacred 🛡️

