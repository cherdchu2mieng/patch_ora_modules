<!-- MANDATORY: All updates and additions to this document MUST strictly follow the /build-rfc skill methodology. -->
# Functional Requirement: Simplified Pulse Init Protocol

## 1. Description
ปรับปรุงขั้นตอนการ `pulse init` ให้มีความเป็นมิตรต่อผู้ใช้งาน (User Friendly) มากขึ้น โดยใช้ระบบ Default-on-Enter และการเลือกขอบเขต (Scope) ที่ชัดเจนระหว่างส่วนตัว (User) และองค์กร (Org)

## 2. Requirements
### 2.1 Context-Aware Scope Selection
- เพิ่มตัวเลือก `Initialize scope: [U]ser or [O]rg? [U]:`
- หากเลือก **[U]ser**:
    - `org` ในคอนฟิกหลักจะใช้ค่าจาก `user git hub name`
    - `projectNumber` ในคอนฟิกหลักจะใช้ค่าจาก `AI Board Team Project Number`
- หากเลือก **[O]rg**:
    - `org` ในคอนฟิกหลักจะใช้ค่าจาก `IT organization`
    - `projectNumber` ในคอนฟิกหลักจะใช้ค่าจาก `IT Master Board Project Number`

### 2.2 Default-on-Enter Pattern
- ทุกคำถามต้องแสดงค่า Default ไว้ใน `[ ]`
- หากผู้ใช้กด **Enter** โดยไม่พิมพ์อะไร ให้ใช้ค่าใน `[ ]` ทันที

### 2.3 Automated Board Mapping
- `board.ITB` จะถูกตั้งค่าตามข้อมูล IT Organization เสมอ
- `board.AIB` จะถูกตั้งค่าตามข้อมูล User เสมอ
- ลอจิกการสร้าง `repo` path ต้องถูกต้องตามสิทธิ์ (Org vs User)

## 3. Acceptance Criteria
- [ ] เมื่อรัน `pulse init` และเลือก [U] ค่า `org` ในไฟล์คอนฟิกต้องเป็นชื่อ GitHub User
- [ ] เมื่อรัน `pulse init` และกด Enter ผ่านทุกข้อ ต้องได้ไฟล์คอนฟิกที่สมบูรณ์และใช้งานได้จริง
- [ ] ไฟล์คอนฟิกที่สร้างต้องมีโครงสร้าง Object สำหรับ `board.ITB` และ `board.AIB` ครบถ้วน
