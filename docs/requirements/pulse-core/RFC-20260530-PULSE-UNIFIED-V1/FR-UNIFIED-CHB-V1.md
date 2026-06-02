# Functional Requirement: Unified Pulse Change Board V1 Standard (FR-UNIFIED-CHB-V1)

## 1. Overview
เอกสารฉบับนี้แจกแจงรายละเอียดการทำงานของคำสั่ง `pulse chb` ภายใต้มาตรฐาน **Protocol V1 (Software v8.5.0)** โดยเน้นความลื่นไหลของการส่งต่องาน (Handover) และความถูกต้องของข้อมูลข้ามบอร์ด

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- สถาปนามาตรฐานการส่งต่องานสองทิศทาง (Handover Flow) ภายใต้โปรโตคอล V1
- รักษาความเชื่อมโยงข้ามบอร์ดผ่านระบบ Anchor ID และ Oracle Identity Check

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: ตรวจสอบ Logic การแกะรอย (Trace) ID ข้ามบอร์ดผ่าน Anchor
- **IG-2 (Security)**: ยืนยันความถูกต้องของ Board Context Guard (ป้องกันสลับบอร์ด)

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.9 confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)

### 3.1 กระบวนการมอบหมายงาน (Ingress Flow: ITB -> AIB)
1.  **Authority Check**: ตรวจสอบว่าผู้สั่งการคือ Oracle ที่ได้รับมอบหมายใน ITB หรือไม่
2.  **Status Gate**: อนุญาตเฉพาะงานที่มีสถานะ `Assigned` หรือ `New` (ที่ระบุ Oracle แล้ว)
3.  **Execution**:
    -   สร้าง Issue ใหม่ใน AIB (Target Oracle Board)
    -   อัปเดตสถานะ ITB เป็น `In Progress` พร้อมใส่ Anchor `AIB-#ID`
    -   อัปเดตสถานะ AIB เป็น `Delegated` พร้อมใส่ Anchor `ITB-#ID`

### 3.2 กระบวนการส่งคืนงาน (Return Flow: AIB -> ITB)
1.  **Authority Check**: ตรวจสอบว่าผู้สั่งการคือ Oracle ผู้รับผิดชอบใน AIB หรือไม่
2.  **Status Gate**: อนุญาตเฉพาะงานที่มีสถานะ `Delegated` (บน AIB)
3.  **Execution**:
    -   อัปเดตสถานะ AIB เป็น `Returned`
    -   ค้นหา ID ของ ITB จาก Anchor และอัปเดตสถานะ ITB เป็น `Done`

## 4. รายละเอียดคำสั่งและ Option (Command Reference)

### 4.1 `pulse chb <ID> --Delegated`
- **พฤติกรรม**: ใช้บน **ITB** เพื่อส่งงานเข้าสู่บอร์ดปฏิบัติการ (AIB)
- **V1 Logic**: ระบบจะตรวจหาบอร์ด AIB ของ Oracle อัตโนมัติจากคอนฟิก

### 4.2 `pulse chb <ID> --Returned`
- **พฤติกรรม**: ใช้บน **AIB** เพื่อส่งคืนงานที่เสร็จแล้วกลับสู่ ITB
- **V1 Logic**: ระบบจะแจ้งเตือนความสำเร็จและแสดง Link ของงานที่ถูกอัปเดตบน ITB

## 5. มาตรฐานการแสดงผล (Output Standard)
- แสดง Banner: `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`
- สรุปการส่งต่อ (Handover Summary):
    - `Source: [Board#ID]`
    - `Target: [Board#ID]`
    - `Action: 🔄 Delegated / ⬆️ Returned`
- ยืนยันผล: `✅ Bidirectional sync completed successfully.`
