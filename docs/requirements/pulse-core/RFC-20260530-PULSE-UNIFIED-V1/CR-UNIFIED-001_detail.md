<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-UNIFIED-001

## 1. Metadata
- **CR ID**: CR-UNIFIED-001
- **Module**: pulse init
- **Technical Objective**: Implement V1 Unified Initialization Standard (v8.5.0)
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred) 🛡️🔒

## 2. Requirement Mapping (From FR-UNIFIED-INIT-V1)
- ยกระดับ `pulse init` ให้เป็นมาตรฐาน Protocol V1
- กำหนด `itinfosv` เป็น Default Organization
- ระบบ Smart Link สำหรับจัดการ Global/Local Config

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 Versioning & Banner Update
- **Target**: `packages/cli/src/commands/init.ts`
- **Action**: เปลี่ยนการแสดงผลเวอร์ชันเป็น `v8.5.0` และโปรโตคอล `V1`
- **Anchor**: จุดที่แสดง Banner เริ่มต้นของคำสั่ง `init`

### 3.2 Organization Defaulting (itinfosv)
- **Target**: `packages/cli/src/commands/init.ts`
- **Action**: แก้ไขค่า Default ใน Prompt การถาม Organization จากค่าว่างหรือค่าเดิม ให้เป็น `itinfosv`
- **Logic**: `const org = await prompt("GitHub org", "itinfosv");`

### 3.3 Path & Symlink Alignment
- **Target**: `packages/cli/src/config.ts` และ `init.ts`
- **Action**: ประกันว่าการสร้างคอนฟิกและ Symlink อ้างอิงโฟลเดอร์ `~/.config/pulse/` อย่างถูกต้องตามมาตรฐานความคงทน

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse init` แสดง Banner V1 (v8.5.0)
- [ ] เมื่อรันคำสั่ง ค่า Default ของ Organization ต้องเป็น `itinfosv`
- [ ] ไฟล์คอนฟิกถูกสร้างใน Global Path และมี Symlink ใน Local
- [ ] Syntax Guard (`bun build`) ผ่านการตรวจสอบ

## 5. Post-Implementation Report
- **Files Modified**:
- packages/cli/src/commands/init.ts
- packages/cli/src/config.ts
- **Duration**: ~2.5 hours (Integrated V1 Cycle)
- **Test Methodology**: Empirical Human Testing (Passed)
