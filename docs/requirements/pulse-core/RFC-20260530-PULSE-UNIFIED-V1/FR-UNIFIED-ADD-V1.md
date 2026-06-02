# Functional Requirement: Unified Pulse Add V1 Standard (FR-UNIFIED-ADD-V1)

## 1. Overview
เอกสารฉบับนี้แจกแจงรายละเอียดการทำงานของคำสั่ง `pulse add` ภายใต้มาตรฐาน **Protocol V1 (Software v8.5.0)** โดยรวมความสามารถด้าน Self-Healing และ Smart Routing จากเวอร์ชันก่อนหน้า

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- รวมความสามารถ Self-Healing และ Smart Routing เข้าสู่มาตรฐานการสร้างงาน V1
- บังคับสถานะเริ่มต้นเป็น `New` และกำหนด Target ไปที่ `itinfosv/pulse-oracle`

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: ตรวจสอบการใช้งาน `gh repo create` สำหรับระบบ Self-Healing
- **IG-2 (Operational)**: ทดสอบการทำงานร่วมกับ Positional Body Argument

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.3 confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)
1.  **Pre-flight Check**:
    -   ตรวจสอบไฟล์คอนฟิก (หากไม่มีให้รัน `init`)
    -   ตรวจสอบตัวตน Oracle ผู้รันคำสั่ง
2.  **Self-Healing Flow**:
    -   ตรวจสอบว่า Repository เป้าหมาย (Default: `itinfosv/pulse-oracle`) มีอยู่หรือไม่
    -   หากไม่มี และผู้ใช้ยืนยัน (หรือเป็นโหมด Auto) ให้สั่ง `gh repo create` พร้อมตั้งค่าบอร์ดเบื้องต้น
3.  **Issue Creation**:
    -   **Title**: รับจาก Argument แรก
    -   **Body**: รับจาก Argument ที่สอง (Positional) หรือ Flag `--body`
    -   **Status**: บังคับเป็น `New`
    -   **Client**: กำหนดเป็น `Human` (หาก Org=itinfosv) หรือ `AI` (หากเป็นบอร์ดรอง)
4.  **Labeling**: ติด Label ตามประเภทงาน (`task`, `bug`, `feature`) และชื่อ Oracle (หากระบุ)

## 4. รายละเอียดคำสั่งและ Option (Command Reference)

### 4.1 `pulse add "Title" ["Body"]`
- **พฤติกรรม**: สร้างงานใหม่โดยใช้ค่าเริ่มต้นของระบบ
- **V1 Logic**: รองรับการพิมพ์ Body ต่อท้าย Title ได้ทันที

### 4.2 `pulse add --oracle <name>`
- **พฤติกรรม**: มอบหมายงานให้ Oracle ที่ระบุทันทีที่สร้าง
- **ความต้องการ**: ระบบต้องตรวจสอบว่า Oracle นั้นมีตัวตนอยู่ใน Fleet หรือไม่

### 4.3 `pulse add --priority <P0-P3>`
- **พฤติกรรม**: กำหนดระดับความสำคัญ (สำหรับ Orchestrator เท่านั้น)

### 4.4 `pulse add --worktree`
- **พฤติกรรม**: สร้าง Issue พร้อมกับสร้าง Git Worktree ในเครื่อง Local ทันที (Integration with `maw`)

## 5. มาตรฐานการแสดงผล (Output Standard)
- แสดง Banner: `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`
- ข้อมูลงานที่สร้าง:
    - `ID: #123`
    - `Target: itinfosv/pulse-oracle`
    - `Status: New`
- ยืนยันการสร้าง: `✅ Task added and tracked on Master Board.`
