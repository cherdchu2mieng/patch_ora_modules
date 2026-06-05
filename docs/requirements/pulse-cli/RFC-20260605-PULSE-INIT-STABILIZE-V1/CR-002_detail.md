<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-002 - Board Data Type Safety & TypeError Fix

## 1. CR Information
- **Parent RFC**: RFC-20260605-PULSE-INIT-STABILIZE-V1
- **Target Module**: pulse-cli (packages/cli/src/config.ts, packages/cli/src/commands/blog.ts)
- **Status**: Approved (Tested from human = Sacred)

## 2. Technical Scope
- **Nature of Change**: Code Hardening & Bug Fix
- **Affected Components**:
    - `config.ts`: เพิ่ม Helper `getBoardRepo(target: "ITB" | "AIB"): string`
    - `blog.ts`: เปลี่ยนมาใช้ Helper แทนการเข้าถึงฟิลด์ Board โดยตรง
- **Logic Description**:
    1. ใน `config.ts` สร้าง `getBoardRepo` ที่ตรวจสอบว่า `cfg.board.[target]` เป็น String หรือ Object:
        - หากเป็น String: คืนค่า String นั้น
        - หากเป็น Object: คืนค่า `board.repo`
    2. ใน `blog.ts` แก้ไขลอจิก Fallback:
        - `const blogRepo = cfg.blog?.repo || getBoardRepo("ITB");`
    3. ตรวจสอบจุดอื่นๆ ที่อาจมีปัญหา TypeError คล้ายกัน (เช่นการหา `projectNumber`)

## 3. Impact Assessment
- **Integration Impact**: แก้ไข Crash ที่เกิดขึ้นใน `pulse blog` และทำให้ระบบมีความทนทานต่อรูปแบบคอนฟิกที่หลากหลาย
- **Regression Risk**: ต่ำ (เป็นการเพิ่ม Helper และใช้ Type Check)

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse blog` ไม่เกิด `TypeError: blogRepo.includes is not a function`
- [ ] สามารถดึงชื่อ Repository ของ IT Master Board ได้ถูกต้องไม่ว่าในคอนฟิกจะเก็บเป็น String หรือ Object

## 5. Post-Implementation Report
- **Actual Files Modified**: `packages/cli/src/config.ts`, `packages/cli/src/commands/blog.ts`
- **Methodology**: Introduced `getBoardRepo` and `getBoardProject` helpers in `config.ts`. Updated `blog.ts` to utilize these helpers, resolving the TypeError when processing Object-based board configurations. Added proper imports.
- **Verification**: Verified via test suite and manual execution of `pulse blog` on a target repository by Human.
- **Status**: Sacred 🛡️
