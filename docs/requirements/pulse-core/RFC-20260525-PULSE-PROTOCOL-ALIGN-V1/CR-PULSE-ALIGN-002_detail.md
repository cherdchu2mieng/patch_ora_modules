# Change Request Detail: CR-PULSE-ALIGN-002

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Commands: board, triage)
- **Target Branch**: feature/protocol-align-viz
- **Worktree Required**: Yes - For clean logic separation.
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification
- **Affected Components**: 
    - `packages/cli/src/commands/board.ts`
    - `packages/cli/src/commands/triage.ts`
- **Logic Description**:
    1. **Config Check (Shared)**: ทั้ง `board` และ `triage` ต้องทำการตรวจสอบไฟล์ `pulse.config.json` ใน CWD ก่อนเริ่มทำงาน หากไม่พบให้แสดง `Run pulse init first.`
    2. **Triage Authority Gate**: 
        - ปรับปรุงตรรกะใน `triage.ts` ให้ทำการเปรียบเทียบค่า `getCurrentOracle()` (ผู้ใช้งานปัจจุบัน) กับค่า `orchestrator` ในคอนฟิก
        - หากไม่ตรงกัน ให้หยุดการทำงานและแจ้งเตือน `Authorization Error: Only the designated Orchestrator can perform board triage.`
    3. **Board Context**: ตรวจสอบการแสดงผลฟิลด์ `Client` และ `Status` ให้ตรงตามข้อมูลล่าสุดที่ได้รับจากการซิงค์
    4. **Alias Registration**: ยืนยันว่าคำสั่งย่อ `tr` ถูกส่งต่อ (Mapped) ไปยัง `triage()` ใน `pulse.ts` อย่างถูกต้อง

## 3. Impact Assessment
- **Integration Impact**: ไม่มีผลกระทบต่อการดึงข้อมูลจาก GitHub แต่เป็นการเพิ่มความปลอดภัยในการเข้าถึงข้อมูล
- **Regression Risk**: ต่ำมาก - เป็นการเพิ่ม Authority Gate และ Config Check

## 4. Acceptance Criteria
- [ ] `pulse board` และ `pulse tr` ต้องหยุดทำงานพร้อมแจ้งเตือนหากไม่มีไฟล์คอนฟิกในโฟลเดอร์ปัจจุบัน
- [ ] ผู้ที่ไม่มีสิทธิ์เป็น Orchestrator จะไม่สามารถรัน `pulse tr` ได้
- [ ] คำสั่ง `pulse tr` แสดงรายการงานที่ขาด Priority, Client หรือ Oracle ได้ถูกต้องแม่นยำ

## 5. Post-Implementation Report
*To be filled after implementation.*
