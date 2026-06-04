<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-001

## 1. CR Information
- **Parent RFC**: RFC-20260604-PULSE-MULTI-PROJECT-CHB-V1
- **Target Module**: pulse-cli (cli)
- **Target Branch**: feature/multi-project-chb-v1
- **Worktree Required**: No
- **Status**: Pending

## 2. Technical Scope
- **Nature of Change**: Modification & Extension
- **Affected Components**: `packages/cli/src/config.ts`
- **Logic Description**:
    1. อัปเดต Interface `PulseConfig`:
       ```typescript
       board?: { 
         ITB: string | { repo: string; projectNumber: number };
         AIB: string | { repo: string; projectNumber: number };
       };
       ```
    2. สร้างฟังก์ชัน `resolveBoardContext(target: "ITB" | "AIB"): PulseContext`
    3. เพิ่ม Logic ตรวจสอบประเภทข้อมูล (String vs Object) และส่งคืน Context ที่ถูกต้อง

## 3. Impact Assessment
- **Integration Impact**: เป็นรากฐานให้ `chb` และ `init` ทำงานได้
- **Regression Risk**: ปานกลาง (ต้องทดสอบกับ Config รูปแบบเดิมให้มั่นใจว่าไม่พัง)

## 4. Acceptance Criteria
- [ ] ฟังก์ชัน `resolveBoardContext` ส่งคืนเลขโปรเจกต์ที่ถูกต้องสำหรับบอร์ดที่เป็น Object
- [ ] ฟังก์ชัน `resolveBoardContext` ส่งคืนเลขโปรเจกต์หลักสำหรับบอร์ดที่เป็น String

## 5. Post-Implementation Report
- **Actual Files Modified**: `packages/cli/src/config.ts`
- **Methodology**: Schema extension and helper function addition.
- **Status**: Sacred 🛡️

