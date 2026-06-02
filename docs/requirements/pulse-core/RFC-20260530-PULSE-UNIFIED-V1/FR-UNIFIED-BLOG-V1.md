# Functional Requirement: Unified Pulse Blog V1 Standard (FR-UNIFIED-BLOG-V1)

## 1. Overview
เอกสารฉบับนี้แจกแจงรายละเอียดการทำงานของคำสั่ง `pulse blog` ภายใต้มาตรฐาน **Protocol V1 (Software v8.5.0)** โดยเน้นการเป็นเครื่องมือสื่อสารหลักของ Orchestrator ในการส่งมอบและประกาศผลงาน

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- สถาปนามาตรฐานการประกาศข่าวสาร (Orchestrator Broadcast) พร้อมระบบ Remote Traceability
- ประกันความสอดคล้องระหว่างเอกสาร Local และบอร์ด GitHub Discussions

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: ตรวจสอบ Logic การ Map URL จากเครื่อง Local ไปยัง GitHub ของ Patch Workspace
- **IG-2 (Operational)**: ยืนยันความสมบูรณ์ของการซิงค์ Frontmatter Metadata

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: `build-patch` (Architecture v3.0)

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.10 confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)
1.  **Authorization Check**: ตรวจสอบสิทธิ์ผู้สั่งการผ่าน `enforceAuth()`
2.  **File Parsing**:
    -   อ่านไฟล์ Markdown และดึงข้อมูล **Frontmatter** (Title, Category, Date)
    -   **Provenance Construction**: แปลง Path `ψ/writing/` ให้เป็น URL บน GitHub ของ `patchWorkspace` ที่ระบุในคอนฟิก
3.  **Content Injection**: แทรกส่วนของ **Provenance Block** ลงในเนื้อหา Discussion เพื่อบอกแหล่งที่มา
4.  **GraphQL Execution**: ส่งคำสั่งสร้างหรืออัปเดต Discussion ไปยัง GitHub API ของ Organization `itinfosv` (หรือตามที่ระบุ)

## 4. รายละเอียดคำสั่งและ Option (Command Reference)

### 4.1 `pulse blog <file.md>`
- **พฤติกรรม**: เผยแพร่ไฟล์ Markdown ที่ระบุไปยัง GitHub Discussions
- **V1 Logic**: ระบบจะตรวจสอบว่าไฟล์อยู่ใน `ψ/writing/` หรือไม่ เพื่อทำการ Map URL ให้ถูกต้อง

### 4.2 `pulse blog --category <name>`
- **พฤติกรรม**: กำหนดหมวดหมู่ของ Discussion (เช่น `Announcements`, `General`)

## 5. มาตรฐานการแสดงผล (Output Standard)
- แสดง Banner: `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`
- ข้อมูลการเผยแพร่:
    - `Title: [ชื่อบทความ]`
    - `Source: [GitHub URL ใน Patch Workspace]`
    - `Target: [itinfosv Discussion URL]`
- ยืนยันผล: `✅ Content successfully published with remote traceability.`
