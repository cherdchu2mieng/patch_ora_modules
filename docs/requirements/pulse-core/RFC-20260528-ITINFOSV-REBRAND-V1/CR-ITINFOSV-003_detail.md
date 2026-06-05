# Change Request Detail: CR-ITINFOSV-003

## 1. Metadata
- **CR ID**: CR-ITINFOSV-003
- **Module**: Installation / Dev Environment
- **Technical Objective**: Realign local Bun global symlinks to the new repository.
- **Execution Skill**: `N` (Manual Shell Commands)
- **Worktree Requirement**: No
- **Status**: Approved (Tested from human = Sacred)

## 2. Requirement Mapping
- แก้ไข Symlinks ในเครื่องผู้ใช้ที่ยังอ้างอิง `Pulse-Oracle/pulse-cli` ให้มาที่ `itinfosv/pulse-cli`
- ประกันว่าการรันคำสั่ง `pulse` แบบ Global จะใช้โค้ดจาก Repository ใหม่

## 3. Step-by-Step Logic

### 3.1 Identify Symlinks
- ตรวจพบที่: `/home/a2it49072/.bun/install/global/node_modules/`
    - `pulse-oracle`
    - `pulse-oracle-cli`

### 3.2 Update Links
- **Action**: ลบลิงก์เดิมและสร้างใหม่ชี้ไปยัง Path ของ `itinfosv`
- **Commands**:
    ```bash
    cd /home/a2it49072/.bun/install/global/node_modules/
    rm pulse-oracle pulse-oracle-cli
    ln -s /home/a2it49072/ghq/github.com/itinfosv/pulse-cli pulse-oracle
    ln -s /home/a2it49072/ghq/github.com/itinfosv/pulse-cli/packages/cli pulse-oracle-cli
    ```

## 4. Acceptance Criteria
- [ ] ลิงก์ใน `.bun/install/global/node_modules/` ชี้ไปยัง `itinfosv/pulse-cli` ถูกต้อง
- [ ] คำสั่ง `ls -l` แสดง Path ใหม่

## 5. Post-Implementation Report
- **Files Modified**: Symlinks in .bun/install/global/node_modules/
- **Duration**: 5 min
- **Test Methodology**: ls -l verification of link targets
- **Status**: Completed (Sacred) 🛡️🌊
