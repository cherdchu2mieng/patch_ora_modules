# Change Request Detail: CR-PULSE-ALIGN-003

## 1. CR Information
- **Parent RFC**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Target Module**: pulse-cli (Commands: set, start)
- **Target Branch**: feature/protocol-align-ops
- **Worktree Required**: Yes - Authority logic is critical.
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification
- **Affected Components**: 
    - `packages/cli/src/commands/set.ts`
    - `packages/cli/src/commands/start.ts`
- **Logic Description**:
    1. **`pulse set` Authority**: เพิ่มการตรวจสอบ `enforceAuth()` เพื่อให้มั่นใจว่าเฉพาะ Orchestrator เท่านั้นที่สามารถแก้ไขบอร์ดได้
    2. **Auto-Client Update**: 
        - ใน `set.ts`, เพิ่มตรรกะตรวจจับการแก้ไขฟิลด์ `Oracle`
        - หากมีการมอบหมายงานให้กลุ่ม `H*` (เช่น H2), ให้ทำการอัปเดตฟิลด์ `Client` เป็น `Human-TEAM` โดยอัตโนมัติ
        - หากมอบหมายให้กลุ่ม `A*` (เช่น A1), ให้ตั้งค่าเป็น `AI-TEAM`
    3. **`pulse start` Authority**:
        - ตรวจสอบว่า `getCurrentOracle()` (ผู้รัน) ตรงกับฟิลด์ `Oracle` บนบอร์ดหรือไม่
        - หากไม่ตรงกัน ให้หยุดการทำงานพร้อมแจ้งเตือนสิทธิ์
    4. **Surgical Status Update**: 
        - เมื่อเริ่มงานสำเร็จ ให้เปลี่ยนสถานะบนบอร์ดเป็น `In Progress` โดยตรง (ไม่ผ่าน `go` หรือ `task`)
    5. **Config Pre-check**: ทั้งสองคำสั่งต้องตรวจสอบไฟล์คอนฟิกใน CWD ก่อนเสมอ

## 3. Impact Assessment
- **Integration Impact**: การอัปเดต Client อัตโนมัติช่วยลดภาระงานของ Orchestrator และประกันความถูกต้องของข้อมูล (Metadata Integrity)
- **Regression Risk**: ปานกลาง - ต้องระวังเรื่องการเปรียบเทียบชื่อ Oracle (Case Sensitivity)

## 4. Acceptance Criteria
- [ ] เฉพาะ Orchestrator เท่านั้นที่สามารถใช้ `pulse set` ได้
- [ ] เมื่อสั่ง `pulse set <#> <H-Name>`, ฟิลด์ Client ต้องเปลี่ยนเป็น `Human-TEAM`
- [ ] เมื่อสั่ง `pulse set <#> <A-Name>`, ฟิลด์ Client ต้องเปลี่ยนเป็น `AI-TEAM`
- [ ] `pulse start` จะทำงานได้เฉพาะเมื่อผู้รันคือผู้ที่ได้รับมอบหมายงานชิ้นนั้นบนบอร์ดเท่านั้น
- [ ] เมื่อรัน `pulse start` สำเร็จ สถานะบนบอร์ดส่วนกลางต้องเปลี่ยนเป็น `In Progress`

## 5. Post-Implementation Report
*To be filled after implementation.*
