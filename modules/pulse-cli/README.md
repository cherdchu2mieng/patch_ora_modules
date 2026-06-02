# Pulse-CLI Module 🌊

โมดูลสำหรับปรับปรุงและเพิ่มความเสถียรให้กับ `pulse-cli` (GitHub Projects Master Board CLI) โดยใช้มาตรฐาน **Ironclad Architecture v3.0**

## 🏁 รุ่นปัจจุบัน: v8.5.0 (🛡️ Unified Protocol V1)

เวอร์ชันนี้คือการอัปเกรดครั้งใหญ่ (Major Upgrade) เพื่อสถาปนามาตรฐาน **Unified Protocol V1** และการปรับเปลี่ยนอัตลักษณ์องค์กรเป็น **`itinfosv`** อย่างสมบูรณ์

### ✨ ฟีเจอร์หลักใน V1 (v8.5.0)

#### 1. Native Rebranding (`itinfosv`)
- ปรับจูนทุกคำสั่งและ Metadata ให้สอดคล้องกับอัตลักษณ์ **itinfosv**
- ระบบเริ่มต้นโครงการ (`pulse init`) มีค่าเริ่มต้นเป็น `itinfosv` พร้อมคำแนะนำภาษาไทย (Bilingual)

#### 2. Ironclad Governance (Authority Gates)
- บังคับใช้ระบบตรวจสอบสิทธิ์ **`enforceAuth()`** ในคำสั่งสำคัญ (`set`, `triage`, `blog`)
- เฉพาะ **Orchestrator** เท่านั้นที่สามารถแก้ไข Metadata ระดับโครงสร้างบอร์ดได้ เพื่อความปลอดภัยสูงสุด

#### 3. Board-Aware Context & Smart Handover
- คำสั่ง **`pulse chb`** (Change Board) ฉลาดขึ้นด้วยการตรวจจับบริบทอัตโนมัติ (ITB vs AIB)
- ระบบ **Bidirectional Anchoring**: สร้างความเชื่อมโยงถาวรระหว่างบอร์ดบริหารและบอร์ดปฏิบัติการผ่านฟิลด์ `Anchor`

#### 4. Symmetrical Lifecycle Synchronization
- **Symmetrical Closure**: `pulse close` จะปิดงานทั้งบนบอร์ดกลางและ GitHub Issue พร้อมกัน 100%
- **Lifecycle Activation**: `pulse start` อัปเดตสถานะและลงวันที่เริ่มงานบนบอร์ดบริหารทันที

#### 5. Precision Visualization (10-Column Board)
- แสดงผล Master Board แบบละเอียด 10 คอลัมน์ พร้อมระบบสี ANSI บอกระดับความสำคัญ (Priority) และสถานะงาน

### 🛡️ Ironclad Standards
1. **Tested from human = Sacred**: โค้ดที่ผ่านการทดสอบจะถูกล็อกสถานะ และมีการทำ **Final Snapshot** เก็บไว้ใน `archive/`
2. **Surgical Precision**: ใช้ระบบ Payload-Based Patching เพื่อความแม่นยำสูงสุด
3. **Traceability First**: ทุกการประกาศข่าวผ่าน `blog` จะมี Link เชื่อมโยงกลับมาที่ Patch Workspace นี้เสมอ

---
**Oracle Signature**: Gemi 🌊 (Deep Blue Horizon)
*"Stable foundations enable dynamic flight. The fleet is unified."*
