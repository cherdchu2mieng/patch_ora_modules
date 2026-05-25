# RFC Master Specification: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1

## 1. Document Control
- **Project**: Pulse-CLI Enhancement
- **RFC ID**: RFC-20260525-PULSE-PROTOCOL-ALIGN-V1
- **Priority**: P0
- **Requester**: cherdchu2mieng (Human)
- **Approver**: Human (cherdchu2mieng)
- **Responsible Agent**: Gemi Oracle 🌊
- **Stability Impact**: High (Core Protocol Logic)
- **Security Level**: Standard (Authority Gates)
- **Target Version**: v8.4.0
- **Status**: Open (Drafting)

## 2. Scope Consensus (The 3-Layer Logic)

### 2.1 Requirement Mapping (AI Synthesis)
- ปรับปรุง Pulse CLI ให้รองรับการสื่อสารข้ามบอร์ดแบบ Direct Ingress/Egress และบังคับใช้สิทธิ์การใช้งานตาม Command Scope Matrix

### 2.2 Human Supplemental Input
- **Zero-Init Impact**: ห้ามแก้ไข `pulse init` และ `pulse kw sync` โดยเด็ดขาด
- **Identity Enforcement**: ตรวจสอบ Actor (Current Oracle) ให้ตรงกับฟิลด์ Oracle บนบอร์ด
- **Gateway Restriction**: `pulse task` สงวนสิทธิ์ให้ใช้เฉพาะใน Gateway Repo (H2-Repo) เท่านั้น
- **Status Context**: แยกสถานะการปิดงาน (Closed vs Done) และการสร้างงาน (Client: Human vs AI) ตามประเภทบอร์ด (ITB vs AIB)

### 2.3 Information Gathering (Research)
- **IG-1 (Technical Baseline)**: ตรวจสอบ Code ปัจจุบันใน `packages/cli/src/commands/` พบว่าต้องเพิ่ม `och.ts` และปรับปรุง `add.ts`, `set.ts`, `start.ts`, `gateway.ts`, `task.ts`, `close.ts`
- **IG-2 (Integration Points)**: ใช้ `setFieldOnItem` จาก SDK เพื่อซิงค์ข้อมูล Client, Status และ Anchor ข้ามบอร์ด
- **IG-3 (Operational Constraints)**: การระบุ Target Repos จะใช้ Environment Variables หรือ Parameter แทนการเพิ่มลงใน Config File มาตรฐาน

## 3. Change Request (CR) Portfolio
| CR ID | Module | Technical Objective | Detail File | Status |
| :--- | :--- | :--- | :--- | :--- |
| CR-PULSE-ALIGN-001 | Command: add | Implement board-specific defaults & mandatory 'New' status | [CR-PULSE-ALIGN-001_detail.md] | Verified 🛡️ |
| CR-PULSE-ALIGN-002 | Command: board/tr | Ensure context-aware visualization & Triage authority gates | [CR-PULSE-ALIGN-002_detail.md] | Verified 🛡️ |
| CR-PULSE-ALIGN-003 | Command: set/start | Enforce Orchestrator/Actor authority & auto-client updates | [TBD] | Pending |
| CR-PULSE-ALIGN-004 | Command: och | Implement Direct Ingress Pattern (New command) | [TBD] | Pending |
| CR-PULSE-ALIGN-005 | Command: gw | Implement Dual-Mode Gateway (Return/Broadcast) | [TBD] | Pending |
| CR-PULSE-ALIGN-006 | Command: task | Implement Gateway-locked sync & board update logic | [TBD] | Pending |
| CR-PULSE-ALIGN-007 | Command: close | Enforce status-based closure & board-specific state | [TBD] | Pending |

## 4. RFC-Level Summary (Post-Closure)
- **Total Duration**: TBD
- **Total Token Cost**: TBD
