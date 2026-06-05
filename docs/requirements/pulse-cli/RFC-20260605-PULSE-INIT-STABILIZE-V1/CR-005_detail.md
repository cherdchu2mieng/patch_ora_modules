<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-005 - Remove Oracle Constraint in AIB Handover

## 1. CR Information
- **Parent RFC**: RFC-20260605-PULSE-INIT-STABILIZE-V1
- **Target Module**: pulse-cli (packages/cli/src/commands/chb.ts)
- **Status**: Approved (Tested from human = Sacred)

## 2. Technical Scope
- **Nature of Change**: Bug Fix (Validation Error)
- **Affected Components**: `packages/cli/src/commands/chb.ts`
- **Logic Description**:
    1. ลบคำสั่ง `await setFieldOnItem(aibCtx, aibItemId, "Oracle", orchestratorName);` ในบล็อก "AIB UPDATE (Target)"
    2. แก้ไขข้อความใน `console.log` ไม่ให้แสดงผลว่าได้กำหนดค่า Oracle
    3. เหตุผล: กระดาน AIB อาจจะไม่ได้มีการกำหนด Option สำหรับ Oracle ชื่อแปลกๆ (เช่น "it49072") ไว้ล่วงหน้าเหมือนในกระดาน ITB การพยายามกำหนดค่าที่ไม่มีในตัวเลือกจึงทำให้เกิด API Error `Option "it49072" not found for field "Oracle"`

## 3. Impact Assessment
- **Integration Impact**: ทำให้ `pulse chb` ทำงานส่งต่องานไปยังบอร์ดย่อย (AIB) ได้ราบรื่น โดยไม่สนใจว่าบอร์ดย่อยจะรู้จักชื่อ Oracle หรือไม่
- **Regression Risk**: ต่ำมาก

## 4. Acceptance Criteria
- [ ] เมื่อรัน `pulse chb` จากบอร์ด ITB ไปบอร์ด AIB จะต้องไม่เกิด Error `Option "..." not found for field "Oracle"`
- [ ] ข้อความยืนยันใน terminal จะไม่ระบุว่ากำหนดค่า Oracle สำเร็จ
