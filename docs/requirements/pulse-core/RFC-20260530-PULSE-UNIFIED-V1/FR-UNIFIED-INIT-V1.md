# Functional Requirement: Unified Pulse Init V1 Standard (FR-UNIFIED-INIT-V1)

## 1. Overview
เอกสารฉบับนี้แจกแจงรายละเอียดการทำงานของคำสั่ง `pulse init` ภายใต้มาตรฐาน **Protocol V1 (Software v8.5.0)** โดยใช้ฐานการทำงานจาก v8.4.0 และปรับปรุงให้เข้ากับอัตลักษณ์ `itinfosv`

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- สถาปนามาตรฐาน `pulse init` ใหม่ (v8.5.0) โดยใช้ฐานความเสถียรจาก v8.4.0
- กำหนดให้ `itinfosv` เป็นอัตลักษณ์เริ่มต้น และระบบจัดเก็บคอนฟิกแบบ Global/Local

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: ตรวจสอบความพร้อมของ `init.ts` ในฐานโค้ด v8.4.0
- **IG-2 (Integration)**: ยืนยันความเข้ากันได้ของระบบ Symlink บน Linux/Tmux
- **IG-3 (Operational)**: ทดสอบการทำงานร่วมกับ Rebranded Workspace (`itinfosv/pulse-cli`)

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)
- **Protocol**: ดำเนินการผ่านระบบ Payloads เพื่อความเสถียร (Sacred Status)

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.1 confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)
1.  **Environment Check**: ตรวจสอบว่ารันอยู่บน `cherdchu2mieng/pulse-cli` fork หรือไม่
2.  **Global Directory Setup**: หากยังไม่มี ให้สร้างโฟลเดอร์ `~/.config/pulse/`
3.  **Identity Discovery Sequence**:
    -   ค้นหาชื่อ Oracle (จาก ENV `ORACLE_NAME` หรือชื่อโฟลเดอร์)
    -   ถาม GitHub Organization (Default: `itinfosv`)
    -   ถาม Scope การทำงาน (User/Org)
4.  **Board Mapping (V1 Standard)**:
    -   หากเป็น Org Mode: Mapping ไปที่ `{Org}/pulse-oracle`
    -   หากเป็น User Mode: Mapping ไปที่ `{User}/pulse-oracle`
5.  **Smart Link Deployment**:
    -   สร้างไฟล์คอนฟิกหลักใน Global Path
    -   สร้าง Symlink ใน Local Workspace
    -   **Self-Healing**: หากบอร์ดเป้าหมายไม่มีใน GitHub ระบบจะเสนอให้สร้างให้อัตโนมัติ (Autonomous Create)

## 4. รายละเอียดคำสั่งและ Option (Command Reference)

### 4.1 `pulse init` (Default Wizard)
- **พฤติกรรม**: เปิดระบบถามตอบแบบโต้ตอบ (Interactive)
- **V1 Logic**: ทุก Prompt จะต้องมีคำแนะนำภาษาไทยกำกับ และ Default ค่า Org เป็น `itinfosv`

### 4.2 `pulse init --org`
- **พฤติกรรม**: ข้ามการถาม Scope และบังคับเข้าสู่โหมดทีมทันที
- **ความต้องการ**: ต้องระบุ Gateway Repository ได้ในขั้นตอนนี้

### 4.3 `pulse init --user`
- **พฤติกรรม**: ตั้งค่าเพื่อใช้งานคนเดียว
- **ความต้องการ**: บอร์ดเป้าหมายจะถูกตั้งค่าไปยัง Repository ส่วนตัวของ User เสมอ

### 4.4 `pulse init --force`
- **พฤติกรรม**: ทำการ Override ค่าคอนฟิกเดิมทั้งหมด
- **ความต้องการ**: ต้องสำรองไฟล์เดิม (Backup) ไว้ใน `~/.config/pulse/backups/` ก่อนเริ่มใหม่

### 4.5 `pulse init --repo <owner/repo>`
- **พฤติกรรม**: กำหนดบอร์ดเป้าหมายโดยไม่ผ่านการคำนวณอัตโนมัติ
- **ความต้องการ**: ระบบต้องตรวจสอบความถูกต้องของ Repo ผ่าน `gh repo view` ก่อนบันทึกค่า

## 5. มาตรฐานการแสดงผล (Output Standard)
- แสดง Banner: `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`
- สรุปค่าที่ตั้งไว้ (Summary Table) ก่อนบันทึก
- แจ้งสถานะการสร้าง Symlink: `✅ Local config linked to global store.`
