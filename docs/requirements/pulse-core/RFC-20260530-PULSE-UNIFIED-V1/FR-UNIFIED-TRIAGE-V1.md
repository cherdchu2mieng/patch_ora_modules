# Functional Requirement: Unified Pulse Triage V1 Standard (FR-UNIFIED-TRIAGE-V1)

## 1. Overview
เอกสารฉบับนี้แจกแจงรายละเอียดการทำงานของคำสั่ง `pulse triage` (หรือ `tr`) ภายใต้มาตรฐาน **Protocol V1 (Software v8.5.0)** โดยเน้นการบริหารจัดการข้อมูลและการควบคุมสิทธิ์ (Governance)

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- สถาปนาระบบ Governance และสิทธิ์การเข้าถึง Triage เฉพาะ Orchestrator
- ตรวจหางานที่ข้อมูลไม่สมบูรณ์ (Missing Metadata) และงานที่ค้างนาน (Stale Tasks)

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: ตรวจสอบ Logic การดึง Metadata ที่ขาดหายผ่าน GraphQL
- **IG-2 (Security)**: ยืนยันความแม่นยำของ `enforceAuth()` สำหรับคำสั่ง `tr`

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.5 confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)

1.  **Orchestrator Gate**:
    -   เรียกใช้ `enforceAuth()` เพื่อประกันว่าเฉพาะผู้ที่มีสิทธิ์ระดับจัดการเท่านั้นที่สามารถใช้งานได้
2.  **Audit Engine (Missing Metadata Detection)**:
    -   ค้นหางานที่ขาด **Priority** (ยังเป็น `---`)
    -   ค้นหางานที่ขาด **Oracle** (ไม่มีคนรับผิดชอบ)
    -   ค้นหางานที่ขาด **Client** (ไม่ระบุแหล่งที่มา)
3.  **Stale Task Threshold**:
    -   ระบุงานที่มีสถานะ `In Progress` แต่ไม่มีการอัปเดตนานเกิน 7 วัน
4.  **Interactive Update Loop**:
    -   แสดงรายการงานที่พบปัญหา
    -   อนุญาตให้ผู้ใช้แก้ไขข้อมูลได้ทันทีผ่านระบบ Prompt หรือแนะนำให้ใช้ `pulse set`

## 4. รายละเอียดคำสั่งและ Option (Command Reference)

### 4.1 `pulse triage` / `pulse tr`
- **พฤติกรรม**: แสดงรายการงานที่ต้องทำการคัดกรอง (Action Required)
- **V1 Logic**: หากไม่มีงานที่ต้องคัดกรอง ระบบจะแจ้งเตือนว่า `✅ Board is healthy.`

## 5. มาตรฐานการแสดงผล (Output Standard)
- แสดง Banner: `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`
- รายการแยกตามหัวข้อปัญหา:
    - `🚩 Missing Metadata: [N] items`
    - `⏳ Stale Tasks: [N] items`
- คำเตือนความปลอดภัย: `🛡️ Governance Mode: Orchestrator Verified`
