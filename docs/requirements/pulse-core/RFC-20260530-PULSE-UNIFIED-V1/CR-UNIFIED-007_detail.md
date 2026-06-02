<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-UNIFIED-007

## 1. Metadata
- **CR ID**: CR-UNIFIED-007
- **Module**: pulse start
- **Technical Objective**: Implement V1 Unified Lifecycle Activation Standard (Compound Start & Identity Gate)
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred) 🛡️🔒

## 2. Requirement Mapping (From FR-UNIFIED-START-V1)
- มาตรฐานการเริ่มงานแบบ Compound Lifecycle (Pull & Anchor + Set In Progress)
- บังคับใช้ Oracle Identity Gate (ตรวจสอบสิทธิ์ผู้รับผิดชอบงาน)
- Surgical Mutation สำหรับอัปเดต Status และ Start Date พร้อมกัน

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 Oracle Identity Gate
- **Target**: `packages/cli/src/commands/start.ts`
- **Action**: เพิ่มลอจิกการเปรียบเทียบ `getCurrentOracle()` กับฟิลด์ `Oracle` (Assignee) จากบอร์ดกลาง หากไม่ตรงกันให้ยกเลิกการทำงาน (ยกเว้นใช้ `--force`)

### 3.2 Compound Execution Logic
- **Target**: `packages/cli/src/commands/start.ts`
- **Action**: ปรับปรุงคำสั่งให้รันฟังก์ชันจาก `task.ts` (เพื่อสร้าง Local Issue และ Anchor) ก่อนทำการอัปเดตสถานะ

### 3.3 Surgical Status & Date Update
- **Target**: `packages/cli/src/commands/start.ts`
- **Action**: ส่ง Mutation ไปยัง GitHub API เพื่อเปลี่ยนสถานะเป็น `In Progress` และบันทึกวันที่ปัจจุบันลงใน `Start Date` ในคราวเดียว

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse start` แสดง Banner V1 (v8.5.0)
- [ ] ไม่อนุญาตให้เริ่มงานหากไม่ใช่ผู้รับผิดชอบ (Oracle Match)
- [ ] สร้าง Issue ใน Local และทำ Cross-link อัตโนมัติหากยังไม่มี
- [ ] สถานะบนบอร์ดเปลี่ยนเป็น `In Progress` และมีวันที่เริ่มงานระบุไว้
- [ ] Syntax Guard (`bun build`) ผ่านการตรวจสอบ

## 5. Post-Implementation Report
- **Files Modified**:
- packages/cli/src/commands/start.ts
- packages/cli/src/pulse.ts
- **Duration**: ~2.5 hours (Integrated V1 Cycle)
- **Test Methodology**: Empirical Human Testing (Passed)
