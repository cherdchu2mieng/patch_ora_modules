# Change Request Detail: CR-ITINFOSV-002

## 1. Metadata
- **CR ID**: CR-ITINFOSV-002
- **Module**: Documentation
- **Technical Objective**: Update README.md with correct repository paths and clone commands.
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred)

## 2. Requirement Mapping
- ปรับปรุงคู่มือการใช้งาน (README.md) ให้สะท้อนถึงเจ้าของใหม่ (`itinfosv`)
- เปลี่ยนลิงก์และคำสั่งที่ใช้ในการติดตั้งให้ชี้ไปยัง Private Repository ที่ถูกต้อง

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 README.md Clone Command
- **Target**: `README.md`
- **Action**: เปลี่ยน `git clone https://github.com/Pulse-Oracle/pulse-cli` เป็น `git clone https://github.com/itinfosv/pulse-cli`

### 3.2 README.md Organization Paths
- **Target**: `README.md`
- **Action**: ค้นหาและเปลี่ยนการอ้างอิงโฟลเดอร์หรือสัญลักษณ์ `Pulse-Oracle/pulse-cli` ทั้งหมดให้เป็น `itinfosv/pulse-cli`

## 4. Acceptance Criteria
- [ ] คำสั่ง `git clone` ใน README.md ชี้ไปยัง `itinfosv`
- [ ] การอ้างอิงชื่อโปรเจกต์ในเอกสารมีความสอดคล้องกับ Repository ใหม่
- [ ] ลิงก์ที่เกี่ยวข้อง (ถ้ามี) สามารถทำงานได้ถูกต้อง

## 5. Post-Implementation Report
- **Files Modified**: README.md
- **Duration**: 10 min
- **Test Methodology**: Manual inspection of clone commands and paths
- **Status**: Completed (Sacred) 🛡️🌊
