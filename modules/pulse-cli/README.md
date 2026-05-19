# Pulse-CLI Module 🌊

โมดูลสำหรับปรับปรุงและเพิ่มความเสถียรให้กับ `pulse-cli` (GitHub Projects Master Board CLI) โดยใช้มาตรฐาน **Ironclad Architecture v3.0**

## 🏁 รุ่นปัจจุบัน: v8.2.1 Stable (🛡️ Tested from human = Sacred)

เวอร์ชันนี้มุ่งเน้นที่ความเสถียรสูงสุดและการป้องกันการถดถอยของฟีเจอร์ (Regression Prevention) ผ่านการบังคับใช้กฎเหล็ก **Stability Protocol**

### ✨ ฟีเจอร์หลัก (Key Features)

#### 1. Advanced Interactive Init
ระบบเริ่มต้นโครงการ (`pulse init`) ที่มีความละเอียดและยืดหยุ่นสูง:
- **Scope Selection**: เลือกได้ทั้งระดับ `[U]ser` (งานส่วนตัว) และ `[O]rg` (งานทีม)
- **One-by-one Discovery**: ในโหมด User ระบบจะถามยืนยันการเพิ่ม Repo ทีละตัว พร้อมให้เปลี่ยนชื่อ (Rename) ได้ทันที
- **Auto-Discovery**: ในโหมด Org ระบบจะแอด Repo ทั้งหมดที่เกี่ยวข้องโดยอัตโนมัติเพื่อความรวดเร็ว
- **Clean Org Config**: แยกข้อมูล Gateway และ Orchestrator ออกจากไฟล์ Org เพื่อรักษาความกลาง (Neutrality)

#### 2. Dynamic Gateway Cross-Sync
- เมื่อ Initialize ในระดับ Org ระบบจะถามหา **Sync Target User**
- ข้อมูล Gateway จะถูกส่งไปอัปเดตที่ไฟล์คอนฟิกของ User โดยอัตโนมัติ ทำให้ Oracle ทุกตัวใน Fleet รู้จักช่องทางการสื่อสารเดียวกัน

#### 3. Robust Keyword Sync (`kw sync`)
- คำสั่ง `pulse keyword sync` (หรือ `kw`) จะดึงค่าจากไฟล์ `CLAUDE.md` ของ Oracle นั้นๆ
- ใช้ระบบ **Deep Cleaning Regex** เพื่อลบ Formatting ส่วนเกินและดึงเฉพาะคำสำคัญที่บริสุทธิ์
- จัดเก็บข้อมูลในรูปแบบ Array มาตรฐาน (`routing.keyword`) ตามต้นฉบับของ Pulse-Oracle

### 🛡️ Stability Protocol (กฎเหล็กการพัฒนา)
ทุกการเปลี่ยนแปลงในโมดูลนี้ต้องยึดถือหลักการ:
1. **Tested from human = Sacred**: สิ่งที่มนุษย์ทดสอบผ่านแล้ว ห้ามแก้ไขโดยไม่ได้รับอนุญาต
2. **Consult First**: ต้องปรึกษาและนำเสนอแผน (Proposal) ก่อนการปรับปรุงฟีเจอร์เดิม
3. **Surgical Precision**: การ Patch ต้องแม่นยำและส่งผลกระทบต่อส่วนอื่นน้อยที่สุด

---
**Oracle Signature**: Gemi 🌊 (Deep Blue Horizon)
*"Stable foundations enable dynamic flight."*
