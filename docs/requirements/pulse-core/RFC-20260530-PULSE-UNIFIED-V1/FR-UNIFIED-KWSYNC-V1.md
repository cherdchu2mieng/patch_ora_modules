# Functional Requirement: Unified Pulse Keyword Sync V1 Standard (FR-UNIFIED-KWSYNC-V1)

## 1. Overview
เอกสารฉบับนี้แจกแจงรายละเอียดการทำงานของคำสั่ง `pulse kw sync` (หรือ `pulse keyword sync`) ภายใต้มาตรฐาน **Protocol V1 (Software v8.5.0)** โดยใช้ฐานการทำงานที่เสถียรจาก v8.2.1

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- ปรับปรุงการซิงค์ Keyword ตัวตน (Bilingual) ให้เป็นปัจจุบันในระบบคอนฟิก V1
- ยึดถือความเสถียรในการดึงข้อมูลจาก `CLAUDE.md` ตามมาตรฐาน v8.2.1

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: ตรวจสอบ Logic การ Parse `CLAUDE.md` เพื่อรองรับ Unicode (ภาษาไทย)
- **IG-2 (Integration)**: ประกันว่าข้อมูล Keyword จะถูกนำไปใช้ในระบบ Routing ของบอร์ด `itinfosv` ได้ถูกต้อง

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.2 confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)
1.  **Identity Verification**: ตรวจสอบว่า `pulse init` ได้ถูกรันเรียบร้อยแล้วและมีไฟล์คอนฟิก
2.  **Source Parsing (`CLAUDE.md`)**:
    -   ค้นหาหัวข้อ **Keywords:** (Case-insensitive)
    -   แยกรายการ Keyword ด้วยเครื่องหมาย Comma (`,`) หรือ Bullet points (`-`)
    -   รองรับ Unicode เพื่อความถูกต้องของภาษาไทย
3.  **Config Merge**:
    -   นำรายการ Keyword ที่ตรวจพบมาเขียนทับฟิลด์ `keywords` ใน `pulse.config.json`
    -   **Preserve Identity**: ห้ามแก้ไขฟิลด์ `oracle` หรือ `repo` ที่ตั้งไว้ในขั้นตอน `init`
4.  **Broadcast (Optional)**: แจ้งเตือนไปยังระบบบอร์ดกลาง (ITB) ว่ามีการอัปเดตตัวตน (หากมีการตั้งค่าเชื่อมต่อ)

## 4. รายละเอียดคำสั่งและ Option (Command Reference)

### 4.1 `pulse kw sync` / `pulse keyword sync`
- **พฤติกรรม**: รันการซิงค์ข้อมูลจาก `CLAUDE.md` ลงสู่คอนฟิกทันที
- **V1 Logic**: หากไม่พบหัวข้อ Keywords ใน `CLAUDE.md` ระบบจะแจ้งเตือนและแนะนำรูปแบบที่ถูกต้อง (Template)

### 4.2 `pulse kw sync --dry-run`
- **พฤติกรรม**: แสดงผล Keyword ที่ตรวจพบในหน้าจอเท่านั้น โดยไม่บันทึกลงไฟล์คอนฟิก
- **ความต้องการ**: ใช้สำหรับการตรวจสอบความถูกต้องก่อนการซิงค์จริง

## 5. มาตรฐานการแสดงผล (Output Standard)
- แสดง Banner: `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`
- รายการ Keyword ที่ตรวจพบ:
    - `Thai: [รายการ...]`
    - `English: [รายการ...]`
- สถานะการบันทึก: `✅ Keywords synchronized to pulse.config.json`
