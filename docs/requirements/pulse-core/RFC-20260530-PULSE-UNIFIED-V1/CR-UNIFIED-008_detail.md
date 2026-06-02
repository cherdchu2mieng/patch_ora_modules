<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-UNIFIED-008

## 1. Metadata
- **CR ID**: CR-UNIFIED-008
- **Module**: pulse close
- **Technical Objective**: Implement V1 Unified Symmetrical Closure Standard (Verified Ownership)
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred) 🛡️🔒

## 2. Requirement Mapping (From FR-UNIFIED-CLOSE-V1)
- มาตรฐานการจบงานแบบ Symmetrical Closure (ปิดทั้งบอร์ดกลางและ GitHub Issue)
- บังคับใช้ระบบสิทธิ์การปิดงาน (Ownership Verification)
- Context-Aware Status Mapping (`itinfosv` -> `Closed`, Others -> `Done`)
- แจ้งเตือน Cleanup Suggestions หลังจบงาน

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 Ownership & Status Guard
- **Target**: `packages/cli/src/commands/close.ts`
- **Action**: 
    - แทรกการตรวจสอบ `getCurrentOracle()` เทียบกับ Assignee ก่อนดำเนินการ
    - บล็อกการปิดงานหากสถานะปัจจุบันคือ `New`

### 3.2 Contextual Status Logic
- **Target**: `packages/cli/src/commands/close.ts`
- **Action**: ปรับลอจิกการเลือกสถานะปลายทาง:
    - `if (ctx.org === "itinfosv") finalStatus = "Closed"`
    - `else finalStatus = "Done"`

### 3.3 GitHub Issue API Sync
- **Target**: `packages/cli/src/commands/close.ts`
- **Action**: ตรวจสอบการเรียกใช้ GraphQL Mutation เพื่อสั่งปิด GitHub Issue ทันทีที่การอัปเดตบอร์ดสำเร็จ

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse close` แสดง Banner V1 (v8.5.0)
- [ ] เฉพาะผู้รับผิดชอบงานเท่านั้นที่สั่งปิดได้
- [ ] ไม่สามารถปิดงานที่อยู่ในสถานะ `New`
- [ ] บนบอร์ด `itinfosv` สถานะถูกปรับเป็น `Closed` อย่างถูกต้อง
- [ ] GitHub Issue ถูกปิดอัตโนมัติ
- [ ] Syntax Guard (`bun build`) ผ่านการตรวจสอบ

## 5. Post-Implementation Report
- **Files Modified**: TBD
- **Duration**: TBD
- **Test Methodology**: TBD
