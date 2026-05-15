# Patch 🌊

Project สำหรับเก็บ Patch, เครื่องมือ (Tools), และการกำหนดค่า (Configurations) สำหรับกองทัพ Oracle (AI-Team Fleet) เพื่อเพิ่มความสามารถและแก้ปัญหาที่ตัวโปรเจกต์ต้นฉบับยังไม่รองรับ

## 🛠️ Unified Dispatcher: `oracle-patch`

เราใช้ระบบ Dispatcher กลางเพื่อให้การจัดการ Patch เป็นไปตามมาตรฐานเดียวกัน (Modular Architecture)

**วิธีใช้:**
```bash
chmod +x bin/oracle-patch
./bin/oracle-patch <module> <target_path>
```

---

## 📦 Available Modules

### 1. `maw-js` (Maw Oracle Core)
โมดูลสำหรับปรับปรุงหัวใจหลักของระบบจัดการ Fleet
- **Safe-Reset & Version Check**: ตรวจสอบเวอร์ชันและล้างสถานะไฟล์เป้าหมายก่อน Patch
- **Full Repo Slugs**: รองรับการสแกน Repo ที่ระบุ domain (เช่น `github.com`)
- **Configurable Groups**: กำหนดลำดับ (Order) และชื่อเซสชันผ่าน `maw.config.json`
- **Auto-resize Tmux**: เปลี่ยน `window-size` เป็น `latest` เพื่อแก้ปัญหาการแสดงผล (dots `...`)
- **Wake All Support**: แทรก logic `maw wake all` เพื่อเปิดการทำงาน Oracle ทั้งหมดในคำสั่งเดียว
- **Patched Indicator**: เพิ่มเครื่องหมาย `(patched 🌊)` ใน `maw --version`

### 2. `pulse-cli` (Pulse Management) - **v7.6 ล่าสุด**
โมดูลสำหรับปรับปรุงระบบจัดการภารกิจ (Master Board)
- **Advanced Syntax (v7.6)**: แยก "หัวข้อ" และ "เนื้อหา" เป็นคนละ Argument (`pulse add "Title" "Body"`) เพื่อความเสถียร
- **Gateway Shortcut**: เพิ่มคำสั่ง `pulse add org` สำหรับส่งงานไปยัง Gateway (Pegasus) อัตโนมัติ พร้อมตั้งค่า **P2**, **Client: IT Board Team** และ **Oracle: pegasus** ทันที
- **Metadata Automation**: รองรับการกำหนด **Priority**, **Client**, และ **Oracle** ลงบน Master Board ทันทีที่สร้าง Issue
- **Lean Init (v7.4)**: ระบบ Symlink คอนฟิกกลาง แทนการสร้างไฟล์ซ้ำซ้อน
- **Org Scope (v7.5)**: รองรับการเลือก Init ระดับ User หรือ Org (เช่น itinfosv)
- **Gateway Cross-Sync**: หากรัน Init ใน Org ระบบจะซิงค์เฉพาะ Repo ปัจจุบันกลับไปที่ User Config หลักอัตโนมัติ (Gateway Bridge)
- **Decentralized Keywords**: ดึง Identity จากไฟล์ `CLAUDE.md` ของแต่ละ Oracle มาสร้าง Routing อัตโนมัติ
- **Patched Indicator**: เพิ่มเครื่องหมาย `(patched 🌊 v7.6)` ใน `pulse --version`

---

## 🧭 คู่มือการตั้งค่าตัวตน (Oracle Identity Setup)

เพื่อให้ระบบ **Pulse** สามารถส่งงาน (Routing) ไปยัง Oracle ที่ถูกต้องได้ แต่ละ Oracle ต้องระบุ Keyword ในไฟล์ `CLAUDE.md` ของตนเองดังนี้:

### การเขียน Keyword ใน `CLAUDE.md`
ใช้รูปแบบหัวข้อ **Keywords:** (ตัวหนาและมี Colon) เพื่อให้สคริปต์ตรวจจับได้:

**Keywords**:
- **English**: visualization, design, infographic, ui, ux
- **Thai**: ออกแบบ, สร้างภาพ, กราฟิก, ยูไอ

---

## 🚀 คู่มือการใช้งาน (Operational Guide)

### สำหรับ Maw (Fleet Management)
1. **Patch**: `./bin/oracle-patch maw-js [path_to_maw_js]`
2. **Scan**: `maw oracle scan` (ค้นหา Repo)
3. **Init**: `maw fleet init` (สร้างไฟล์ลำดับเซสชัน)
4. **Wake**: `maw wake all` (เริ่มการทำงานทั้งหมด)

### สำหรับ Pulse (Task Orchestration)
1. **Patch**: `./bin/oracle-patch pulse-cli [path_to_pulse_cli]`
2. **Init**: `pulse init` ในโฟลเดอร์โครงการ
   - เลือกระดับ User สำหรับโครงการส่วนตัว
   - เลือกระดับ Org สำหรับโครงการทีม (ระบบจะสร้าง Gateway เชื่อมกับ User ให้อัตโนมัติ)
3. **Add Task**:
   - `pulse add "หัวข้อ" "รายละเอียด"` (Syntax ใหม่ v7.6)
   - `pulse add org "หัวข้อ"` (ส่งงานเข้า Gateway/Pegasus ทันที)
4. **Keyword Sync**: รันคำสั่งเพื่อซิงค์ตัวตนเข้าบอร์ดกลาง
   ```bash
   pulse keyword sync  # หรือ pulse kw sync
   ```

---
**Oracle Signature**: Gemi 🌊 (Deep Blue Horizon)
*"Identity is declared; systems are synchronized."*
