<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Functional Requirement: Multi-Project Number Support (FR-1)

## 1. Overview
ความต้องการนี้มุ่งเน้นการแก้ปัญหาคอขวดในกระบวนการ Handover (chb) เมื่อ Oracle ทำงานข้ามองค์กรหรือข้ามบอร์ดที่มีเลขโปรเจกต์ไม่ตรงกัน

## 2. Scope Consensus (The 4-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- ระบบต้องรองรับการกำหนดเลขโปรเจกต์แยกตามบอร์ด (ITB/AIB)
- ระบบต้องฉลาดพอที่จะเลือกใช้เลขโปรเจกต์ที่ถูกต้องตามบริบทบอร์ดที่กำลังทำงานอยู่
- รักษาความเสถียรสำหรับผู้ใช้ที่มี Config รูปแบบเดิม

### 2.2 Information Gathering (Research)
- **IG-1 (Technical)**: SDK รองรับการส่ง `projectNumber` ผ่าน `PulseContext` อยู่แล้ว แต่ CLI ยังขาดการเตรียม Context ที่หลากหลาย
- **IG-2 (Operational)**: ปัจจุบันการ `chb` ข้ามบอร์ดที่เลขโปรเจกต์ต่างกันจะเกิด Error จาก GitHub API

### 2.3 Implementation Governance (Layer 4)
- **Execution Skill**: build-patch

### 2.4 Pathway (Confirmation)
- **Confirm Command**: **`brfc-Phase 3.x confirm`**

## 3. ตรรกะการทำงานหลัก (Core Logic)
1. เมื่อเริ่มคำสั่ง `chb`, ระบบจะตรวจสอบค่า `board` ใน Config
2. หากบอร์ดนั้นเป็น Object ให้ดึง `projectNumber` จากภายใน Object
3. หากบอร์ดเป็น String หรือไม่มีข้อมูล ให้ใช้ `projectNumber` หลักของระบบ
4. สร้าง Context แยกกันสำหรับ `itbCtx` และ `aibCtx` ก่อนเรียกใช้งาน API

## 4. รายละเอียดโครงสร้าง JSON (Standard Reference)
```json
{
  "projectNumber": 1,
  "board": {
    "ITB": { "repo": "itinfosv/pulse-oracle", "projectNumber": 1 },
    "AIB": { "repo": "cherdchu2mieng/pulse-oracle", "projectNumber": 6 }
  }
}
```

## 5. มาตรฐานการแสดงผล (Output Standard)
- ในหน้าจอ `init` ต้องแสดงคำถามแยกสำหรับแต่ละบอร์ด
- ข้อความแจ้งเตือน Error ต้องระบุเลขโปรเจกต์ที่ทำให้เกิดปัญหาได้ชัดเจน
