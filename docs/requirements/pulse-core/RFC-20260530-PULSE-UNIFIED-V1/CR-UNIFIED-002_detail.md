<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-UNIFIED-002

## 1. Metadata
- **CR ID**: CR-UNIFIED-002
- **Module**: pulse board
- **Technical Objective**: Implement V1 Unified Visualization Standard (10 Columns with Anchor)
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred) 🛡️🔒

## 2. Requirement Mapping (From FR-UNIFIED-BOARD-V1)
- แสดงผลตารางงานมาตรฐาน V1 ครบทั้ง 10 คอลัมน์
- **Anchor Field**: ต้องแสดงรหัสเชื่อมโยงข้ามบอร์ด (เช่น `AIB-#123`) เพื่อการตรวจสอบย้อนกลับ
- **Responsive Table**: ระบบตัดคำอัตโนมัติและความถูกต้องของภาษาไทย

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 GraphQL Query Update
- **Target**: `packages/sdk/src/github.ts`
- **Action**: เพิ่มฟิลด์ `Anchor` (หรือฟิลด์ที่เก็บ Metadata การเชื่อมโยง) ลงใน Query ที่ใช้ดึงข้อมูล Project V2 Items

### 3.2 Table Rendering Update
- **Target**: `packages/cli/src/commands/board.ts`
- **Action**: 
    - ปรับปรุงอาเรย์คอลัมน์ให้รวม `Anchor` เข้าไป
    - ตั้งค่าความกว้าง (Width) ของคอลัมน์ Anchor ให้เหมาะสม (ประมาณ 10-12 ตัวอักษร)
    - ปรับลอจิกการ Truncate ในคอลัมน์ `Title` ให้เหลือพื้นที่สำหรับคอลัมน์ใหม่

### 3.3 Semantic Color Alignment
- **Target**: `packages/cli/src/commands/board.ts`
- **Action**: ประกันว่าสี ANSI สำหรับ Priority และ Status เป็นไปตามมาตรฐาน V1

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse board` แสดงผลครบ 10 คอลัมน์ รวมถึงคอลัมน์ **Anchor**
- [ ] ข้อมูลในคอลัมน์ Anchor แสดงผลถูกต้อง (เช่น `AIB-#123` หรือ `---`)
- [ ] ตารางไม่แตกเมื่อรันในหน้าจอที่มีความกว้างมาตรฐาน (80-100 columns)
- [ ] ภาษาไทยใน Title ไม่ทำให้การจัดเรียงคอลัมน์เบี้ยว

## 5. Post-Implementation Report
- **Files Modified**: TBD
- **Duration**: TBD
- **Test Methodology**: TBD
