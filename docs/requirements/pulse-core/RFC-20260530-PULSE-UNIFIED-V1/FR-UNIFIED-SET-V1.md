# Functional Requirement: Unified Pulse Set V1 Standard (FR-UNIFIED-SET-V1)

## 1. Overview
เอกสารฉบับนี้แจกแจงรายละเอียดการทำงานของคำสั่ง `pulse set` ภายใต้มาตรฐาน **Protocol V1 (Software v8.5.0)** โดยเน้นความปลอดภัยระดับ Orchestrator และระบบ Auto-detection

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- บังคับใช้สิทธิ์ Orchestrator Gate และระบบ Auto-detection สำหรับการแก้ไขบอร์ด V1
- รองรับการระบุ ID ด้วยเครื่องหมาย `#` และการจับคู่ฟิลด์อัตโนมัติ

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: ตรวจสอบความแม่นยำของ Pattern Matching สำหรับ Auto-detection
- **IG-2 (Operational)**: ทดสอบการอัปเดตหลายฟิลด์ในคำสั่งเดียวบนบอร์ด `itinfosv`

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.6 confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)
1.  **Authorization Check**:
    -   เรียกใช้ `enforceAuth()` เพื่อตรวจสอบว่าผู้ใช้ปัจจุบันคือ Orchestrator ของโครงการหรือไม่
    -   หากไม่ใช่ ระบบจะปฏิเสธการแก้ไข (ยกเว้นบางฟิลด์ที่อนุญาต เช่น Label ส่วนตัว)
2.  **ID Parsing**:
    -   รองรับ ID ในรูปแบบตัวเลขล้วน (เช่น `123`) หรือมีเครื่องหมายนำหน้า (เช่น `#123`)
3.  **Value Auto-Detection**:
    -   **Priority**: ตรวจจับรูปแบบ `P0`, `P1`, `P2`, `P3`
    -   **Client**: ตรวจจับ `Human`, `AI`, หรือใช้ Auto-Client Protocol (`H*`/`A*`)
    -   **Oracle**: ตรวจจับชื่อ Oracle ที่มีอยู่ในระบบ
    -   **Status**: ตรวจจับสถานะมาตรฐาน (`New`, `In Progress`, `Done`, `Closed`, `Paused`)
4.  **Mutation Execution**:
    -   ส่งคำสั่งอัปเดตไปยัง GitHub Project V2 API
    -   บันทึกการเปลี่ยนแปลงลงในประวัติของ Issue (Comment)

## 4. รายละเอียดคำสั่งและ Option (Command Reference)

### 4.1 `pulse set <ID> <Value1> [<Value2> ...]`
- **พฤติกรรม**: อัปเดตข้อมูลงานตามค่าที่ระบุ
- **V1 Logic**: ลำดับของค่าไม่สำคัญ ระบบจะใช้การจับคู่รูปแบบ (Pattern Matching) เพื่อระบุฟิลด์

### 4.2 `pulse set <ID> --clear <field>`
- **พฤติกรรม**: ล้างค่าในฟิลด์ที่กำหนด (เช่น `Start Date`, `Target Date`)

## 5. มาตรฐานการแสดงผล (Output Standard)
- แสดง Banner: `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`
- ตารางสรุปการเปลี่ยนแปลง (Before/After):
    - `Field: Priority | Old: --- | New: P1`
- ยืนยันผล: `✅ Board metadata updated successfully.`
- กรณีไม่มีสิทธิ์: `❌ Unauthorized: Only Orchestrator can modify this board.`
