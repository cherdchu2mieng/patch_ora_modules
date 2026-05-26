# Change Request Detail: CR-PULSE-ALIGN-007

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: close)
- **Target Branch**: feature/protocol-align-close
- **Worktree Required**: Yes - Final state logic.
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification
- **Affected Components**: 
    - `packages/cli/src/commands/close.ts`
- **Logic Description**:
    1. **Closure Restriction**: ตรวจสอบสถานะของไอเทมก่อนปิดงาน หากสถานะปัจจุบันเป็น **`New`** ให้หยุดการทำงานและแจ้งเตือนว่าไม่สามารถปิดงานที่ยังไม่ได้เริ่มหรือมอบหมายได้
    2. **Context-Aware Status**:
        - อ่านค่า `org` จากคอนฟิกไฟล์ใน CWD
        - หาก `org === "itinfosv"` (บอร์ดบริหารจัดการ), ให้เปลี่ยนสถานะเป็น **`Closed`**
        - หากไม่ใช่ (เช่น AIB หรือบอร์ดปฏิบัติงาน), ให้เปลี่ยนสถานะเป็น **`Done`**
    3. **SDK Sync**: ใช้ `setFieldOnItem` เพื่อบันทึกสถานะปลายทางที่ถูกต้อง
    4. **Idempotency**: ประกันว่าคำสั่งสามารถรันซ้ำได้หากงานถูกปิดไปแล้วโดยไม่ทำให้เกิด Error

## 3. Impact Assessment
- **Integration Impact**: ทำให้การปิดงานในแต่ละเลเยอร์ (Human vs AI) มีความหมายและสถานะที่แตกต่างกันตามบริบทของบอร์ด
- **Regression Risk**: ต่ำ - เป็นการเพิ่มเงื่อนไขการคัดกรองสถานะ

## 4. Acceptance Criteria
- [ ] ระบบต้องไม่อนุญาตให้ปิดงานที่มีสถานะเป็น `New`
- [ ] เมื่อรันในสภาพแวดล้อมของ `itinfosv`, สถานะต้องถูกอัปเดตเป็น `Closed`
- [ ] เมื่อรันในสภาพแวดล้อมอื่น (ทีม AI), สถานะต้องถูกอัปเดตเป็น `Done`
- [ ] การปิดงานต้องส่งผลทั้งบนบอร์ดบริหารจัดการและ GitHub Issue ที่เกี่ยวข้อง

## 5. Post-Implementation Report
*To be filled after implementation.*
