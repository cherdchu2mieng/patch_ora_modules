# Functional Requirement: Unified Pulse Start V1 Standard (FR-UNIFIED-START-V1)

## 1. Overview
เอกสารฉบับนี้แจกแจงรายละเอียดการทำงานของคำสั่ง `pulse start` ภายใต้มาตรฐาน **Protocol V1 (Software v8.5.0)** โดยเน้นการรวบรวมวงจรชีวิตงาน (Lifecycle) ให้เป็นหนึ่งเดียว

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- สถาปนามาตรฐานการเริ่มงานแบบ Compound Lifecycle (Pull + InProgress) ใน V1
- บังคับใช้ Oracle Identity Gate เพื่อประกันความถูกต้องของผู้รับผิดชอบงาน

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: ตรวจสอบประสิทธิภาพของ Surgical Mutation สำหรับ Status & Start Date
- **IG-2 (Operational)**: ทดสอบการทำงานร่วมกับระบบ `task` pulling

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.7 confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)
1.  **Identity Verification**:
    -   ตรวจสอบตัวตน Oracle ปัจจุบันใน Workspace
    -   ดึงข้อมูล Assignee จากบอร์ดกลางมาเปรียบเทียบ
    -   **Gate**: หากตัวตนไม่ตรงกัน ให้หยุดการทำงานและแจ้งเตือน
2.  **Surgical Mutation (V1 Optimization)**:
    -   อัปเดตฟิลด์ `Status` เป็น `In Progress`
    -   อัปเดตฟิลด์ `Start Date` เป็นวันที่ปัจจุบัน
3.  **Local Anchoring (Task Pulling)**:
    -   ตรวจสอบว่ามีการสร้าง Issue ใน Local แล้วหรือยัง
    -   หากยังไม่มี ให้รันกระบวนการ `pulse task` เพื่อสร้าง Issue และทำ Cross-link (`Parent: #ID`)
4.  **Operational Logging**:
    -   บันทึกการเริ่มงานลงใน Comment ของ Issue ทั้งในบอร์ดกลางและ Local

## 4. รายละเอียดคำสั่งและ Option (Command Reference)

### 4.1 `pulse start <ID>`
- **พฤติกรรม**: เริ่มต้นการทำงานตาม ID ที่ระบุ
- **V1 Logic**: ระบบจะตรวจสอบสถานะปัจจุบันของงาน หากงานเสร็จไปแล้วหรือถูกปิด จะไม่อนุญาตให้เริ่มใหม่โดยไม่มีการ Re-open

### 4.2 `pulse start --force`
- **พฤติกรรม**: บังคับเริ่มงานแม้ว่าตัวตน Oracle จะไม่ตรงกัน (ใช้สำหรับกรณี Orchestrator ช่วยเริ่มงานให้)

## 5. มาตรฐานการแสดงผล (Output Standard)
- แสดง Banner: `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`
- สรุปการเริ่มงาน:
    - `Task ID: #123`
    - `Status: ⚡ In Progress`
    - `Start Date: 2026-05-30`
- การแจ้งเตือนความปลอดภัย: `🛡️ Oracle Identity Verified: [Name]`
- ยืนยันผล: `✅ Task is now active and linked to your workspace.`
