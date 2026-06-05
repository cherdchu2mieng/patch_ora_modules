<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-001 - Simplified Init Flow & Context Mapping

## 1. CR Information
- **Parent RFC**: RFC-20260605-PULSE-INIT-STABILIZE-V1
- **Target Module**: pulse-cli (packages/cli/src/commands/init.ts)
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Prompt Logic Refactoring
- **Affected Components**: `init.ts` (init function)
- **Logic Description**:
    1. ปรับปรุงฟังก์ชัน `ask` ให้รับค่า Default และคืนค่า Default ทันทีหาก input ว่างเปล่า
    2. ลำดับคำถามใหม่:
        - Scope? [U/O]
        - IT Organization [itinfosv]
        - IT Master Board Project Number [1]
        - User GitHub name [login]
        - AI Board Team Project Number [1]
        - Gateway Oracle
        - Orchestrator Oracle
    3. ลอจิกการคำนวณ Identity:
        - `isOrg = scope === 'o'`
        - `config.org = isOrg ? githubOrg : githubUser`
        - `config.projectNumber = isOrg ? itbProj : aibProj`
    4. ลอจิกการสร้าง Board Object:
        - `board.ITB = { repo: "${githubOrg}/pulse-oracle", projectNumber: itbProj }`
        - `board.AIB = { repo: githubUser, projectNumber: aibProj }` (หมายเหตุ: AIB repo อาจจะเป็นแค่ชื่อ User ตามความต้องการ)

## 3. Impact Assessment
- **Integration Impact**: เปลี่ยนโครงสร้างการเก็บข้อมูลใน `pulse.config.json` ให้เป็นมาตรฐานใหม่
- **Regression Risk**: ปานกลาง (ต้องตรวจสอบว่าไม่มีฟิลด์เดิมสูญหาย)

## 4. Acceptance Criteria
- [ ] เมื่อกด Enter ผ่านทุกคำถาม ระบบต้องใช้ค่า Default ที่ระบุไว้ใน `[ ]`
- [ ] ผลลัพธ์ใน `pulse.config.json` ต้องมี `org` และ `projectNumber` ตรงตาม Scope ที่เลือก
- [ ] `board.ITB` และ `board.AIB` ถูกบันทึกเป็น Object
