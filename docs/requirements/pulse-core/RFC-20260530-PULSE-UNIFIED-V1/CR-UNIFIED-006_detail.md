<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Change Request Detail: CR-UNIFIED-006

## 1. Metadata
- **CR ID**: CR-UNIFIED-006
- **Module**: pulse set
- **Technical Objective**: Implement V1 Unified Board Modification Standard (Auth Gate & Auto-detection)
- **Execution Skill**: `build-patch` (v2.7)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred) 🛡️🔒

## 2. Requirement Mapping (From FR-UNIFIED-SET-V1)
- บังคับใช้สิทธิ์ Orchestrator Gate สำหรับการแก้ไขบอร์ด
- ระบบ Auto-detection ระบุประเภทฟิลด์อัตโนมัติ
- รองรับการระบุ ID ด้วยเครื่องหมาย `#`
- ปรับปรุงการแสดงผลสรุปการเปลี่ยนแปลงภายใต้ Banner V1

## 3. Step-by-Step Logic (For Robust-Patching)

### 3.1 Authority Gate Integration
- **Target**: `packages/cli/src/commands/set.ts`
- **Action**: ตรวจสอบการเรียกใช้ `enforceAuth()` เพื่อให้แน่ใจว่าเฉพาะ Orchestrator เท่านั้นที่สามารถเปลี่ยนฟิลด์สำคัญ (Status, Priority, Client)

### 3.2 Intelligent Field Mapping Refinement
- **Target**: `packages/cli/src/commands/set.ts`
- **Action**: ปรับปรุงฟังก์ชันการตรวจจับค่า (Value Parsing) ให้ครอบคลุม:
    - **Priority**: P0-P3
    - **Status**: New, In Progress, Done, Closed, Paused
    - **Client**: Human, AI, หรือ Auto-group (`H*`/`A*`)

### 3.3 ID Parsing & Banner Update
- **Target**: `packages/cli/src/commands/set.ts`
- **Action**: 
    - ปรับลอจิกการรับค่า ID ให้ตัดเครื่องหมาย `#` ออกก่อนประมวลผล
    - ปรับปรุงการแสดงผล Banner เป็น `🌊 Pulse CLI Unified Protocol V1 (v8.5.0)`

## 4. Acceptance Criteria
- [ ] คำสั่ง `pulse set` แสดง Banner V1 (v8.5.0)
- [ ] ปฏิเสธการแก้ไขหากไม่ใช่ Orchestrator (ยกเว้นฟิลด์ที่ได้รับอนุญาต)
- [ ] สามารถตั้งค่าโดยไม่ระบุชื่อฟิลด์ (เช่น `pulse set 1 P1 sky`)
- [ ] รองรับ ID แบบ `#123`
- [ ] Syntax Guard (`bun build`) ผ่านการตรวจสอบ

## 5. Post-Implementation Report
- **Files Modified**:
- packages/cli/src/commands/set.ts
- packages/cli/src/pulse.ts
- **Duration**: ~2.5 hours (Integrated V1 Cycle)
- **Test Methodology**: Empirical Human Testing (Passed)
