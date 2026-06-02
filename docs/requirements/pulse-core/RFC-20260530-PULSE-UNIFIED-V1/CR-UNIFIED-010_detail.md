<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-UNIFIED-010

## 1. Metadata
- **CR ID**: CR-UNIFIED-010
- **Module**: pulse blog
- **Technical Objective**: Implement V1 Unified Broadcast Standard (Orchestrator Broadcast & Remote Traceability)
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred) 🛡️🔒

## 2. Requirement Mapping (From FR-UNIFIED-BLOG-V1)
- มาตรฐานการประกาศข่าวสารทางการ (Orchestrator Broadcast)
- ระบบ **Remote Traceability**: แปลง Path `ψ/writing/` เป็น GitHub URL อัตโนมัติ
- รองรับการซิงค์ **Frontmatter Metadata** และแสดงตราประทับ V1

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 Remote Path Mapping Logic
- **Target**: `packages/cli/src/commands/blog.ts`
- **Action**: ปรับปรุงฟังก์ชันการสร้าง URL โดยใช้สูตร: `[patchWorkspace]/blob/main/docs/requirements/[mappedPath]`

### 3.2 Frontmatter & Branding Injection
- **Target**: `packages/cli/src/commands/blog.ts`
- **Action**: 
    - แทรกข้อความ `🌊 Published via Pulse Unified Protocol V1 (v8.5.0)` ลงในส่วนท้ายของบทความ
    - ยืนยันการดึง Title และ Category จาก Frontmatter มาใช้ในการสร้าง Discussion

### 3.3 Authorization & Banner
- **Target**: `packages/cli/src/commands/blog.ts`
- **Action**: 
    - เรียกใช้ `enforceAuth()` เพื่อจำกัดสิทธิ์ให้เฉพาะ Orchestrator
    - ปรับปรุงการแสดงผล Banner เป็น `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse blog` แสดง Banner V1 (v8.5.0)
- [ ] เฉพาะ Orchestrator เท่านั้นที่สามารถใช้งานได้
- [ ] บทความบน GitHub Discussions มี Link เชื่อมโยงกลับไปยัง Patch Workspace ที่ถูกต้อง
- [ ] แสดงตราประทับ V1 ในเนื้อหาบทความ
- [ ] Syntax Guard (`bun build`) ผ่านการตรวจสอบ

## 5. Post-Implementation Report
- **Files Modified**: TBD
- **Duration**: TBD
- **Test Methodology**: TBD
