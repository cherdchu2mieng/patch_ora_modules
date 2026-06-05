<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-003 - Board Context Alignment (chb fix)

## 1. CR Information
- **Parent RFC**: RFC-20260605-PULSE-INIT-STABILIZE-V1
- **Target Module**: pulse-cli (packages/cli/src/commands/chb.ts)
- **Status**: Approved (Tested from human = Sacred)

## 2. Technical Scope
- **Nature of Change**: Consistency Alignment
- **Affected Components**: `chb.ts`
- **Logic Description**:
    1. ตรวจสอบการใช้งาน `resolveBoardContext` ใน `chb.ts`
    2. แก้ไขจุดที่อาจเกิดการอ้างอิงตัวแปรผิดพลาด (เช่น `aibOrgContext` ที่อาจจะไม่มีใน Scope นั้น)
    3. ยืนยันว่าการทำงานแบบ Bidirectional Link (ITB <-> AIB) ใช้ข้อมูลจากโครงสร้าง Object ใหม่ได้อย่างถูกต้อง

## 3. Impact Assessment
- **Integration Impact**: ทำให้การส่งต่องาน (Handover) ระหว่างบอร์ด ITB และ AIB มีความแม่นยำสูงขึ้น
- **Regression Risk**: ต่ำ

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse chb` ทำงานได้โดยไม่อ้างอิงตัวแปรที่ไม่ได้นิยาม
- [ ] การเลือก Repo ของ AIB ต้องใช้ค่าจาก `board.AIB.repo` เสมอ

## 5. Post-Implementation Report
- **Actual Files Modified**: `packages/cli/src/commands/chb.ts`
- **Methodology**: Aligned context resolution to use `resolveBoardContext` for both ITB and AIB. Fixed missing imports (`resolveBoardContext`, `getCurrentOracle`).
- **Verification**: Verified via manual handover execution (`pulse chb <id>`) to ensure context and bidirectional link establishment works correctly without reference errors.
- **Status**: Sacred 🛡️
