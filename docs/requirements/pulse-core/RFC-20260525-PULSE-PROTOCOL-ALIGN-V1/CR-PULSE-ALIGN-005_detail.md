# Change Request Detail: CR-PULSE-ALIGN-005

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: gateway/gw)
- **Target Branch**: feature/protocol-align-gw
- **Worktree Required**: Yes - Critical for egress logic.
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification
- **Affected Components**: 
    - `packages/cli/src/commands/gateway.ts`
- **Logic Description**:
    1. **Authority Gate**: บังคับใช้ `enforceAuth()` เพื่อให้เฉพาะ Orchestrator AI เท่านั้นที่สามารถส่งงานคืนได้
    2. **Target Gate**: ล็อก Repository ปลายทางให้เป็น Gateway Repo (เช่น H2-Repo)
    3. **Mode A (Return Flow)**:
        - เมื่อรับค่าเป็นเลข Issue (e.g., `pulse gw 50`)
        - ดึงข้อมูล **Anchor** จาก Issue นั้น (เช่น `ITB-#101`)
        - สร้าง Issue ใหม่ใน Gateway Repo พร้อมสถานะ **`Returned`**
        - ตั้งค่า `Client` เป็น **`H2`** (Oracle Gateway)
        - ฝังค่า Anchor เดิมลงใน Body เพื่อให้ `task` ซิงค์กลับได้ถูกต้อง
    4. **Mode B (Broadcast Flow)**:
        - เมื่อรับค่าเป็นหัวข้อและเนื้อหา (e.g., `pulse gw "Title" "Body"`)
        - สร้าง Issue ใหม่ใน Gateway Repo พร้อมสถานะ **`broadcast`**
        - ตั้งค่า `Client` เป็น **`IT Board Team`**

## 3. Impact Assessment
- **Integration Impact**: เป็นจุดส่งมอบงานคืน (Egress) ที่ประกันว่าบอร์ดฝั่งมนุษย์จะได้รับสัญญาณการเสร็จสิ้นงานอย่างเป็นทางการ
- **Regression Risk**: ต่ำ - เป็นการปรับปรุงตรรกะภายในของคำสั่งเดิม

## 4. Acceptance Criteria
- [ ] เฉพาะ Orchestrator AI เท่านั้นที่สามารถรันคำสั่งนี้ได้
- [ ] Mode A: Issue ใน Gateway Repo ต้องมีสถานะ `Returned` และ Anchor ที่ถูกต้อง
- [ ] Mode B: Issue ใน Gateway Repo ต้องมีสถานะ `broadcast` และ Client เป็น `IT Board Team`
- [ ] ทุกการส่งงานต้องไปปรากฏที่ Gateway Repo ที่กำหนดไว้เท่านั้น

## 5. Post-Implementation Report
*To be filled after implementation.*
