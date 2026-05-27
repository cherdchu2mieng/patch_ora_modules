# Change Request Detail: CR-PULSE-INIT-V821

## 1. CR Information
- **Parent RFC**: RFC-20260518-STABILIZE
- **Target Module**: pulse-cli
- **Target Branch**: feature/pulse-v8.2.1-stable
- **Status**: Sacred (Tested from human = Sacred)

## 2. Technical Scope
- **Nature of Change**: Modification of existing init logic.
- **Affected Components**: packages/cli/src/commands/init.ts
- **Logic Description**: Implement iterative repo selection for User mode and auto-discovery for Org mode.

## 3. Impact Assessment
- **Integration Impact**: Affects how users first onboard to the system.
- **Regression Risk**: Risk of losing personal config (Mitigated by .bak files).

## 4. Post-Implementation Report
- **Actual Files Modified**: packages/cli/src/commands/init.ts, patch_pulse.sh
- **Actual Duration**: ~90 min
- **Actual Token Cost**: ~80k
- **Changes Done**: Stabilized one-by-one repo selection.
