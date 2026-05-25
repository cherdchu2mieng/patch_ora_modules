# Change Request Detail: CR-PULSE-ALIGN-004

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Command: och)
- **Target Branch**: feature/protocol-align-och
- **Worktree Required**: Yes - New command implementation.
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: New Module
- **Affected Components**: 
    - `packages/cli/src/commands/och.ts` (New file)
    - `packages/cli/src/commands/index.ts` (Export)
    - `packages/cli/src/pulse.ts` (CLI registration)
- **Logic Description**:
    1. **Pre-flight Validation**: 
        - รับค่า `<index>` ของไอเทมบนบอร์ดบริหารจัดการ (ITB)
        - ตรวจสอบว่าผู้รัน (`Actor`) ตรงกับชื่อในฟิลด์ `Oracle` หรือไม่
        - ตรวจสอบว่า `Status === "Assigned"` และ `Client === "Human-TEAM"` หรือไม่
    2. **Target Resolution**: ค้นหา Repository ปลายทางของ AI Orchestrator (เช่น A1-Repo) ผ่าน Environment Variable `PULSE_A1_REPO` หรือ Parameter (เพื่อเลี่ยงการแก้ไข Init)
    3. **Cross-board Issue Creation**: 
        - สร้าง Issue ใหม่ใน Target Repo
        - กำหนดหัวข้อตามต้นฉบับ
        - ฝังข้อมูล **Anchor** (เช่น `ITB-#101`) ลงใน Body ของ Issue
    4. **Field Initialization (Remote)**:
        - ตั้งสถานะที่ปลายทางเป็น **`Delegated`**
        - ตั้งค่า `Client` เป็นชื่อของผู้รัน (เช่น `H2`) เพื่อระบุผู้ส่งงาน

## 3. Impact Assessment
- **Integration Impact**: เป็นจุดเชื่อมต่อหลัก (Ingress) ระหว่างทีมมนุษย์และทีม AI ทำให้เกิด Traceability ตั้งแต่วินาทีแรกของการส่งงาน
- **Regression Risk**: ต่ำ - เป็นการเพิ่มฟังก์ชันใหม่ที่แยกตัวออกมาอิสระ

## 4. Acceptance Criteria
- [ ] หากเงื่อนไข Pre-flight ไม่ครบ (เช่น Oracle ไม่ตรง หรือ Status ไม่ใช่ Assigned) ระบบต้องไม่อนุญาตให้ส่งงาน
- [ ] Issue ใหม่ใน AI Repo ต้องมี Anchor กลับมายัง ITB อย่างชัดเจน
- [ ] สถานะที่ปลายทางต้องเป็น `Delegated` และ Client ต้องเป็นชื่อผู้ส่งงาน
- [ ] ระบบต้องทำงานได้โดยไม่ต้องเพิ่มคอนฟิกใหม่ลงใน `pulse.config.json`

## 5. Post-Implementation Report
*To be filled after implementation.*
