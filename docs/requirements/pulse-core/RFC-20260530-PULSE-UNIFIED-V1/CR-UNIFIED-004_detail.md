<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-UNIFIED-004

## 1. Metadata
- **CR ID**: CR-UNIFIED-004
- **Module**: pulse kw sync
- **Technical Objective**: Implement V1 Unified Identity Synchronization Standard (v8.5.0)
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred) 🛡️🔒

## 2. Requirement Mapping (From FR-UNIFIED-KWSYNC-V1)
- ซิงค์ Keyword ตัวตน (Bilingual) จาก `CLAUDE.md` ลงสู่คอนฟิก V1
- รักษาความเสถียรของลอจิกการดึงข้อมูลตามมาตรฐาน v8.2.1
- ปรับปรุงการแสดงผลสรุป Keyword ที่ตรวจพบภายใต้ Banner V1

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 Banner & Versioning Update
- **Target**: `packages/cli/src/commands/keyword.ts`
- **Action**: ปรับปรุงการแสดงผล Banner เป็น `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`

### 3.2 CLAUDE.md Parsing Alignment
- **Target**: `packages/cli/src/commands/keyword.ts`
- **Action**: ยืนยันการใช้ Regex ที่รองรับ Unicode เพื่อดึงข้อมูลหลังหัวข้อ **Keywords:** อย่างแม่นยำ

### 3.3 Config Integration Refinement
- **Target**: `packages/cli/src/commands/keyword.ts`
- **Action**: ปรับปรุงลอจิกการบันทึกให้ทำการ Merge เฉพาะฟิลด์ `keywords` โดยไม่กระทบต่อโครงสร้าง `orchestrator` หรือ `board` ใหม่ใน V1

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse kw sync` แสดง Banner V1 (v8.5.0)
- [ ] สามารถดึง Keyword ภาษาไทยและอังกฤษจาก `CLAUDE.md` ได้ถูกต้อง
- [ ] ข้อมูลใน `pulse.config.json` ถูกอัปเดตเฉพาะส่วนของ Keywords
- [ ] Syntax Guard (`bun build`) ผ่านการตรวจสอบ

## 5. Post-Implementation Report
- **Files Modified**:
- packages/cli/src/commands/keyword.ts
- packages/cli/src/commands/index.ts
- packages/cli/src/pulse.ts
- **Duration**: ~2.5 hours (Integrated V1 Cycle)
- **Test Methodology**: Empirical Human Testing (Passed)
