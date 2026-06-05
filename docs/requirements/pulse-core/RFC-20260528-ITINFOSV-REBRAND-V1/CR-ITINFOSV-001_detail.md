# Change Request Detail: CR-ITINFOSV-001

## 1. Metadata
- **CR ID**: CR-ITINFOSV-001
- **Module**: Metadata / GitHub Workflows
- **Technical Objective**: Rebrand repository URLs and organization references in system files.
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred)

## 2. Requirement Mapping
- เปลี่ยน URL ของ Repository ในไฟล์การตั้งค่าระบบให้ชี้ไปยัง `itinfosv/pulse-cli` แทนที่ต้นฉบับเดิม
- ปรับปรุงชื่อ Organization ใน GitHub Actions เพื่อความถูกต้องในการระบุตัวตน

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 `package.json` Update
- **Target**: `package.json`
- **Action**: Replace `https://github.com/Pulse-Oracle/pulse-cli` with `https://github.com/itinfosv/pulse-cli` in the `repository.url` field.

### 3.2 `.github/workflows/inbox-auto-add.yml` Update
- **Target**: `.github/workflows/inbox-auto-add.yml`
- **Action**: 
    - ตรวจสอบและเปลี่ยนการแจ้งเตือนจาก `maw hey pulse-oracle` เป็นชื่อที่เหมาะสม (หากต้องการ) หรือรักษาไว้หากเป็นชื่อ Agent หลัก
    - ยืนยันว่า `${{ github.repository }}` จะคืนค่าเป็น `itinfosv/pulse-cli` โดยอัตโนมัติ

## 4. Acceptance Criteria
- [ ] ไฟล์ `package.json` ระบุ URL ถูกต้องและสามารถเข้าถึงได้
- [ ] ไม่มีคำว่า `Pulse-Oracle` หลงเหลืออยู่ในไฟล์ที่กำหนด
- [ ] Syntax Guard (`bun packages/cli/src/pulse.ts --help`) ผ่านการตรวจสอบ

## 5. Post-Implementation Report
- **Files Modified**: package.json, .github/workflows/inbox-auto-add.yml
- **Duration**: 20 min
- **Test Methodology**: Syntax Guard & Grep verification
- **Status**: Completed (Sacred) 🛡️🌊
