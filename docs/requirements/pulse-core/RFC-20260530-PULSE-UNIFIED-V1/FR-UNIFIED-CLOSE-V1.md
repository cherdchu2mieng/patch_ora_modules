# Functional Requirement: Unified Pulse Close V1 Standard (FR-UNIFIED-CLOSE-V1)

## 1. Overview
เอกสารฉบับนี้แจกแจงรายละเอียดการทำงานของคำสั่ง `pulse close` (หรือ `pulse done`) ภายใต้มาตรฐาน **Protocol V1 (Software v8.5.0)** โดยเน้นความถูกต้องของสิทธิ์และการจบวงจรชีวิตงานที่สมบูรณ์

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- สถาปนามาตรฐานการจบงานแบบ Symmetrical Closure (Board + GitHub) ใน V1
- บังคับใช้ระบบสิทธิ์การปิดงาน (Ownership) และการจัดการสถานะตามบริบทบอร์ด

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: ตรวจสอบความถูกต้องของระบบปิด GitHub Issue ผ่าน API
- **IG-2 (Operational)**: ทดสอบการแสดงผล Cleanup Suggestions หลังการปิดงาน

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.8 confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)
1.  **Identity Verification**:
    -   ตรวจสอบตัวตน Oracle ปัจจุบัน
    -   ดึงข้อมูลงานจากบอร์ดกลางเพื่อตรวจสอบ Assignee
    -   **Gate**: หากตัวตนไม่ตรงกัน ให้ปฏิเสธการปิดงาน (Security Gate)
2.  **Status Guard**:
    -   ตรวจสอบสถานะปัจจุบันของงาน
    -   **Gate**: หากสถานะเป็น `New` ให้แจ้งเตือนว่าต้องเริ่มงานก่อนปิด (Lifecycle Protection)
3.  **Context-Aware Status Mapping**:
    -   หากอยู่ในบอร์ด `itinfosv/pulse-oracle` -> กำหนดสถานะเป็น `Closed`
    -   หากอยู่ในบอร์ดทีม AI อื่นๆ -> กำหนดสถานะเป็น `Done`
4.  **Synchronization & Cleanup**:
    -   อัปเดตสถานะบน Master Board ผ่าน SDK
    -   สั่งปิด GitHub Issue ที่เกี่ยวข้อง
    -   **Suggestion**: แสดงคำแนะนำให้ผู้ใช้ล้าง Git Worktree (หากตรวจพบว่าทำงานใน Worktree)

## 4. รายละเอียดคำสั่งและ Option (Command Reference)

### 4.1 `pulse close <ID>` / `pulse done <ID>`
- **พฤติกรรม**: จบการทำงานตาม ID ที่ระบุ
- **V1 Logic**: ระบบจะตรวจสอบความสอดคล้องของข้อมูลและสิทธิ์ก่อนดำเนินการเสมอ

### 4.2 `pulse close --force`
- **พฤติกรรม**: บังคับปิดงานแม้สิทธิ์จะไม่ตรงกัน (สำหรับ Orchestrator เท่านั้น)

## 5. มาตรฐานการแสดงผล (Output Standard)
- แสดง Banner: `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`
- สรุปการปิดงาน:
    - `Task ID: #123`
    - `Final Status: ✅ Done` (หรือ `Closed`)
- การแจ้งเตือนความปลอดภัย: `🛡️ Verified Assigned Oracle: [Name]`
- ยืนยันผล: `✅ Task successfully closed on Master Board and GitHub.`
- คำแนะนำหลังการปิด: `💡 Hint: You can now remove the worktree for this task.`
