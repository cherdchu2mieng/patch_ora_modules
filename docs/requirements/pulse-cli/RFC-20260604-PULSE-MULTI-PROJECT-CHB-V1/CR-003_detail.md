<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-003

## 1. CR Information
- **Parent RFC**: RFC-20260604-PULSE-MULTI-PROJECT-CHB-V1
- **Target Module**: pulse-cli (cli)
- **Target Branch**: feature/multi-project-chb-v1
- **Worktree Required**: No
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification
- **Affected Components**: `packages/cli/src/commands/init.ts`
- **Logic Description**:
    1. ปรับปรุง Prompt ในส่วนการตั้งค่าบอร์ด
    2. เพิ่มการถามเลขโปรเจกต์เมื่อผู้ใช้กำหนดชื่อบอร์ด
    3. จัดรูปแบบข้อมูลให้เป็น Object ก่อนบันทึกลง `pulse.config.json`

## 3. Impact Assessment
- **Integration Impact**: ปรับปรุงประสบการณ์การใช้งานครั้งแรก (User Experience)
- **Regression Risk**: ต่ำมาก

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse init` สามารถสร้าง Config ที่มีเลขโปรเจกต์แยกตามบอร์ดได้สำเร็จ

## 5. Post-Implementation Report
- **Actual Files Modified**: `packages/cli/src/commands/init.ts`
- **Methodology**: Updated interactive flow to ask for board-specific project numbers.
- **Status**: Sacred 🛡️

