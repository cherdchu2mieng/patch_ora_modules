<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-UNIFIED-009

## 1. Metadata
- **CR ID**: CR-UNIFIED-009
- **Module**: pulse chb
- **Technical Objective**: Implement V1 Unified Handover Standard (Bidirectional Sync)
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred) 🛡️🔒

## 2. Requirement Mapping (From FR-UNIFIED-CHB-V1)
- ระบบส่งต่องานสองทิศทาง (Handover Flow)
- **Ingress (ITB -> AIB)**: สร้างงานในบอร์ดปฏิบัติการและทำ Anchor กลับ
- **Return (AIB -> ITB)**: อัปเดตงานในบอร์ดจัดการเมื่อเสร็จสิ้นผ่าน Anchor
- บังคับใช้ Oracle Identity Gate และ Board Context Guard

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 Ingress Logic (Delegated)
- **Target**: `packages/cli/src/commands/chb.ts`
- **Action**: 
    - ตรวจสอบชื่อ Oracle จาก Workspace ปัจจุบันเทียบกับบอร์ด
    - สร้าง Issue ใหม่ใน AIB และอัปเดตฟิลด์ `Anchor` ในทั้งสองบอร์ด
    - อัปเดตสถานะเป็น `In Progress` (ITB) และ `Delegated` (AIB)

### 3.2 Return Logic (Returned)
- **Target**: `packages/cli/src/commands/chb.ts`
- **Action**: 
    - แกะรอย ID ต้นทางจากฟิลด์ `Anchor` (เช่น `ITB-#123`)
    - อัปเดตสถานะเป็น `Returned` (AIB) และ `Done` (ITB)

### 3.3 Context Guard & Banner
- **Target**: `packages/cli/src/commands/chb.ts`
- **Action**: 
    - บล็อกการใช้ `--Delegated` บนบอร์ดที่เป็น AIB อยู่แล้ว
    - ปรับปรุงการแสดงผล Banner เป็น `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse chb` แสดง Banner V1 (v8.5.0)
- [ ] การส่งต่อ (Delegated) สร้างงานในบอร์ดที่ถูกต้องและมี Link เชื่อมโยง
- [ ] การส่งคืน (Returned) อัปเดตสถานะบอร์ดหลักเป็น `Done` โดยอัตโนมัติ
- [ ] ไม่อนุญาตให้ข้ามสิทธิ์ Oracle ในการทำรายการ
- [ ] Syntax Guard (`bun build`) ผ่านการตรวจสอบ

## 5. Post-Implementation Report
- **Files Modified**:
- packages/cli/src/commands/chb.ts
- packages/cli/src/commands/index.ts
- packages/cli/src/pulse.ts
- **Duration**: ~2.5 hours (Integrated V1 Cycle)
- **Test Methodology**: Empirical Human Testing (Passed)
