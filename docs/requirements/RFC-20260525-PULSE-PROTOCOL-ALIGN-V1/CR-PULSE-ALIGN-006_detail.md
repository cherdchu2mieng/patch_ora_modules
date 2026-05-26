# Change Request Detail: CR-PULSE-ALIGN-006

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: task)
- **Target Branch**: feature/protocol-align-task
- **Worktree Required**: Yes - Structural changes to task logic.
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification
- **Affected Components**: 
    - `packages/cli/src/commands/task.ts`
- **Logic Description**:
    1. **Location Gate**: ตรวจสอบ Directory ปัจจุบัน (CWD) ว่าคือ Repository ที่เป็น Gateway (เช่น H2-Repo) หรือไม่ หากไม่ใช่ให้หยุดการทำงาน
    2. **Logic A (If Item Status = `Returned`)**:
        - อ่านค่ารหัสงาน AI (เช่น `AIB-#50`) จาก Issue ปัจจุบัน
        - เชื่อมต่อไปยังบอร์ดบริหารจัดการ (ITB) ตามที่ระบุใน Anchor (เช่น `ITB-#101`)
        - ทำการอัปเดตสถานะที่ ITB ให้เป็น **`Closed`**
        - ผูกรหัสงาน AI ลงในฟิลด์ **Anchor** บน ITB เพื่อทำ Audit Trail
    3. **Logic B (If Item Status = `broadcast`)**:
        - ตรวจพบสถานะการประกาศข่าวสาร
        - ดำเนินการสร้างรายงานบนบอร์ดบริหารจัดการ (ITB) โดยใช้คำสั่ง **`pulse blog`** (หรือ Internal Logic ที่เทียบเท่า)
    4. **SDK Sync**: ใช้ `gh` และ `setFieldOnItem` เพื่อส่งข้อมูลข้ามโปรเจกต์บอร์ด

## 3. Impact Assessment
- **Integration Impact**: เป็นการปิดวงจรการทำงาน (Cycle Closure) ที่ช่วยให้บอร์ดระดับบริหารได้รับการอัปเดตโดยอัตโนมัติจากจุด Gateway
- **Regression Risk**: ปานกลาง - ต้องจัดการเรื่องการยืนยันตัวตนและการเข้าถึงบอร์ดข้าม Organization (ถ้ามี)

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse task` ต้องไม่ทำงานหากไม่ได้รันใน Gateway Repo
- [ ] เมื่อพบสถานะ `Returned`, ระบบต้องปิดงานที่ ITB และบันทึก AI Anchor ได้ถูกต้อง
- [ ] เมื่อพบสถานะ `broadcast`, ระบบต้องสร้างรายการ Blog ที่ ITB ได้สำเร็จ
- [ ] ข้อมูลความเชื่อมโยง (Traceability) ระหว่างบอร์ดต้องชัดเจนและตรวจสอบย้อนกลับได้

## 5. Post-Implementation Report
*To be filled after implementation.*
