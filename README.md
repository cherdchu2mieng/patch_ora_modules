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

### 2. `pulse-cli` (Pulse Management)
โมดูลสำหรับปรับปรุงระบบจัดการภารกิจ (Master Board)
- **Automated Init**: ปรับปรุงคำสั่ง `pulse init` ให้ฉลาดขึ้น
- **Routing Engine**: สร้าง `label` และ `repo` routing อัตโนมัติจากรายชื่อ Oracle ที่ค้นพบ
- **Multilingual Support**: ใส่ชุด **Thai Keywords** มาตรฐาน (จัดการ, ค้นหา, ออกแบบ, ฯลฯ) ลงในคอนฟิกเริ่มต้น
- **Default Sentinel**: ตั้งค่า Default Target ไปที่ `pulse` บอร์ด เพื่อป้องกันงานตกหล่น

---

## 🧭 คู่มือการใช้งาน (Operational Guide)

### สำหรับ Maw (Fleet Management)
1. **Patch**: `./bin/oracle-patch maw-js [path_to_maw_js]`
2. **Scan**: `maw oracle scan` (ค้นหา Repo)
3. **Init**: `maw fleet init` (สร้างไฟล์ลำดับเซสชัน)
4. **Wake**: `maw wake all` (เริ่มการทำงานทั้งหมด)

### สำหรับ Pulse (Task Orchestration)
1. **Patch**: `./bin/oracle-patch pulse-cli [path_to_pulse_cli]`
2. **Init**: `pulse init` ในโฟลเดอร์โครงการ เพื่อสร้าง `pulse.config.json` ที่สมบูรณ์
3. **Sync**: คัดลอกคอนฟิกไปยังระดับระบบ: `cp pulse.config.json ~/.config/pulse/pulse.config.json`

---
**Oracle Signature**: Gemi 🌊 (Deep Blue Horizon)
*"Patterns over intentions; modular patches over monolithic chaos."*
