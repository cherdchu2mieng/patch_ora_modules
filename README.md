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

### 2. `pulse-cli` (Pulse Management) - **v7.7 ล่าสุด**
โมดูลสำหรับปรับปรุงระบบจัดการภารกิจ (Master Board)
- **Dynamic Gateway (v7.7)**: ระบบจัดการ Gateway แบบไดนามิก ไม่มีการ Hardcode ค่าในซอร์สโค้ดอีกต่อไป
- **Integrated Init**: `pulse init` ในโหมด Org จะถามข้อมูล Gateway (Repo, Oracle, Client, Priority) และบันทึกลงใน `pulse.config.json` ให้โดยอัตโนมัติ
- **Smart Add Routing**: คำสั่ง `pulse add org` จะอ่านค่าคอนฟิกจากไฟล์โดยตรง ทำให้รองรับ Human หลายคนที่มี Gateway ต่างกันได้อย่างสมบูรณ์
- **Comprehensive Patch**: รวมความสามารถจาก v7.5 (Org Scope) และ v7.6 (Advanced Syntax) ไว้ในตัวเดียว
- **Patched Indicator**: อัปเดตเป็น `(patched 🌊 v7.7)` ใน `pulse --version`

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
   - เลือกระดับ Org สำหรับโครงการทีม (ถามข้อมูล Gateway อัตโนมัติ v7.7)
3. **Add Task**:
   - `pulse add "หัวข้อ" "รายละเอียด"` (Syntax ใหม่ v7.7)
   - `pulse add org "หัวข้อ"` (ส่งงานผ่าน Dynamic Gateway ตามคอนฟิก v7.7)
4. **Keyword Sync**: รันคำสั่งเพื่อซิงค์ตัวตนเข้าบอร์ดกลาง
   ```bash
   pulse keyword sync  # หรือ pulse kw sync
   ```

---
**Oracle Signature**: Gemi 🌊 (Deep Blue Horizon)
*"Identity is declared; systems are synchronized."*
