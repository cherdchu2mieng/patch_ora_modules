<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Functional Requirement: Board-Aware Config Compatibility Fix

## 1. Description
แก้ไขปัญหาความไม่เข้ากันของข้อมูล (Type Mismatch) ในคำสั่ง `pulse blog` และคำสั่งอื่นๆ ที่มีการเข้าถึงข้อมูล Board โดยตรง เพื่อรองรับการเก็บข้อมูลแบบ Object

## 2. Requirements
### 2.1 TypeError Resolution (pulse blog)
- แก้ไขลอจิก Fallback ใน `blog.ts` ที่พยายามเรียก `.includes("/")` บน Object
- เพิ่มการตรวจสอบประเภทข้อมูล (Type Check) ก่อนใช้งาน หากเป็น Object ให้ดึงค่าฟิลด์ `repo` ออกมา

### 2.2 Robust Helper Implementation
- ปรับปรุง Helper `resolveBoardContext` ใน `config.ts` ให้เป็นมาตรฐานกลางที่ทุกคำสั่งต้องเรียกใช้
- ยืนยันว่า `pulse chb` และคำสั่งอื่นๆ ทำงานร่วมกับข้อมูล Board ที่เป็น Object ได้อย่างไร้รอยต่อ

## 3. Acceptance Criteria
- [ ] คำสั่ง `pulse blog` สามารถรันได้โดยไม่เกิด `TypeError` แม้ `board.ITB` จะเป็น Object
- [ ] การดึงข้อมูล `repo` และ `projectNumber` จาก Board Config ต้องถูกต้องในทุกสภาวะ (String vs Object)
