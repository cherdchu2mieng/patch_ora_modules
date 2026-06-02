# Functional Requirement: Unified Pulse Board V1 Standard (FR-UNIFIED-BOARD-V1)

## 1. Overview
เอกสารฉบับนี้แจกแจงรายละเอียดการทำงานของคำสั่ง `pulse board` (หรือ `b`) ภายใต้มาตรฐาน **Protocol V1 (Software v8.5.0)** โดยเน้นการแสดงผลข้อมูลแบบครบวงจร (Full Visibility)

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- แสดงผลสถานะงาน 10 คอลัมน์ภายใต้มาตรฐาน Protocol V1
- ประกันความ Responsive และความถูกต้องของการแสดงผลภาษาไทย

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: ตรวจสอบการใช้ `process.stdout.columns` สำหรับ Responsive Truncation
- **IG-2 (Operational)**: ยืนยันความสอดคล้องของ ANSI Colors กับ Dark/Light Theme

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.4 confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)
1.  **Multi-Column Fetch (10 Columns)**:
    -   `ID`, `Title`, `Pri` (Priority), `Status`, `Oracle`, `Client`, `Start` (Start Date), `Target` (Target Date), **`Anchor` (Cross-link ID)**, `Repo` (Origin)
2.  **Responsive Layout Engine**:
    -   คำนวณความกว้างหน้าจอผ่าน `process.stdout.columns`
    -   ลำดับความสำคัญของคอลัมน์ (Column Priority): หากหน้าจอแคบ ให้ตัด `Dates` และ `Repo` ออกก่อน และทำการ Truncate `Title` เป็นลำดับสุดท้าย
3.  **ANSI Semantic Coloring**:
    -   **Priority**: P0 (แดง), P1 (เหลือง), P2 (ฟ้า), P3 (เทา)
    -   **Status**: Done/Closed (เขียว), In Progress (ฟ้า), New (ขาว), Paused (ส้ม)
4.  **Bilingual Table Alignment**:
    -   จัดการความกว้างของตัวอักษรไทย (Double-width detection) เพื่อไม่ให้ Padding ของตารางเพี้ยน

## 4. รายละเอียดคำสั่งและ Option (Command Reference)

### 4.1 `pulse board` / `pulse b`
- **พฤติกรรม**: แสดงตารางงานทั้งหมดที่ยังไม่ถูกปิด (Open Tasks)

### 4.2 `pulse board [filter]`
- **พฤติกรรม**: กรองข้อมูลตาม Keyword (เช่น `pulse board Neo` หรือ `pulse board P0`)
- **ความต้องการ**: การกรองต้องเป็นแบบ Case-insensitive และตรวจสอบทุกคอลัมน์หลัก

## 5. มาตรฐานการแสดงผล (Output Standard)
- แสดง Banner: `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`
- สรุปสถิติ: `Total: [N] | New: [N] | In Progress: [N] | Done: [N]`
- ตาราง ASCII ที่จัดรูปเล่มสวยงาม (Clean Layout)
