# Windows Optimizer — Milestones

## Milestone 1: Project Scaffold & Entry Point

**Files:** `setup.ps1`, `windows10-11/optimize.ps1`, `library.ps1` (stubs)

- Create directory structure (`windows10-11/`)
- Implement `setup.ps1`:
  - Admin check with auto-elevation via `Start-Process powershell -Verb RunAs`
  - OS version detection via `(Get-WmiObject Win32_OperatingSystem).Version`
  - Routing logic (Windows 10/11 → gaming branch; others → exit with message)
- Stub out `windows10-11/optimize.ps1` with a main menu skeleton
- Stub out `library.ps1` with an empty `$AppLibrary` hashtable
- Temp file creation at `$env:TEMP\wo_session.tmp` with initial key=value pairs
- Registration of `WO_Cleanup` scheduled task (fallback cleanup)
- Explicit temp file deletion on all exit paths

**Definition of Done:**
- Running `setup.ps1` as Admin detects the OS, routes to the gaming branch (Windows 10/11), shows the main menu, and cleans up the temp file on exit.

---

## Milestone 2: Dependencies & Temp File

**Files:** `setup.ps1`

- Implement all dependency checks per the PRD table:
  - `winget` check → auto-install via `Add-AppxPackage` if missing
  - GPU brand detection via `Get-WmiObject Win32_VideoController`
  - PowerShell version check → warn if below 5.1
- Write all results to `wo_session.tmp`
- Temp file re-creation logic if file goes missing mid-session

**Definition of Done:**
- All dependencies are checked, auto-installed if possible, and results are persisted in the temp file. Re-running the check recreates the file correctly.

---

## Milestone 3: Feature 1 — Privacy & Telemetry

**Files:** `windows10-11/optimize.ps1`

- Implement all registry/policy changes listed under "Privacy & Telemetry" in the PRD
- Stop and disable `DiagTrack` and `dmwappushservice` services
- Line-by-line status output with color coding (Green for success, Red for failure)
- Summary at end showing count of applied vs failed changes

**Definition of Done:**
- Selecting option [1] from the main menu applies all telemetry hardening changes and displays a status summary.

---

## Milestone 4: Feature 2 — Debloat Windows

**Files:** `windows10-11/optimize.ps1`

- Define the curated list of UWP packages to remove (all 22 listed in PRD)
- Loop: `Get-AppxPackage` → `Remove-AppxPackage` per package
- Silent error handling per package, log pass/fail
- End summary: count of removed vs failed

**Definition of Done:**
- Selecting option [2] from the main menu removes targeted UWP apps and shows a final count of successes and failures.

---

## Milestone 5: Feature 3 — App Installer (Picker + Library)

**Files:** `windows10-11/optimize.ps1`, `library.ps1`

- Populate `library.ps1` with the full `$AppLibrary` hashtable (Gaming, Browsers, Programming categories and apps)
- Implement GPU app injection: read temp file, inject NVIDIA/AMD/Intel app into a "System" category
- Build the interactive picker UI:
  - Category boxes rendered in 2–3 columns based on terminal width
  - Toggle boxes: `[ ]` / `[x]` with color change (Cyan when selected)
  - Arrow key navigation, Spacebar to toggle, `I` to install, `ESC` to go back
- Implement the install loop with `winget install --id ... --silent ...`
- End screen with success/failure lists and `[R]` / `[0]` options

**Definition of Done:**
- Selecting option [3] from the main menu shows the picker, allows multi-select, installs chosen apps, and displays a summary.

---

## Milestone 6: Feature 4 — Update Drivers

**Files:** `windows10-11/optimize.ps1`

- Install all-in-one runtimes via winget (VCRedist x64/x86, DirectX, .NET Runtime 8, .NET Desktop 8, XNA Redist)
- Same skip-and-log error model as app installer

**Definition of Done:**
- Selecting option [4] from the main menu installs runtimes, logging results for each.

---

## Milestone 7: Feature 5 — Optimize System

**Files:** `windows10-11/optimize.ps1`

- Confirmation prompt: `[Y] Apply all  [N] Cancel`
- Apply all performance/UX changes:
  - Disable Delivery Optimization P2P upload
  - Set refresh rate to maximum (P/Invoke via DEVMODE)
  - Disable mouse acceleration (registry + P/Invoke `SystemParametersInfo`)
  - Set power plan to High Performance via `powercfg`
  - Set visual effects to performance mode
  - Disable Xbox Game Bar
  - Disable startup delay
  - Disable hibernation via `powercfg /hibernate off`
- Line-by-line status, summary at end

**Definition of Done:**
- Selecting option [5] from the main menu shows a confirmation prompt, applies all optimizations, and displays a summary.

---

## Milestone 8: UX Polish & Error Handling Hardening

**Files:** All

- Verify all UX conventions are met:
  - Color scheme consistent (Cyan highlight, Green success, Red failure, Yellow warnings)
  - `[Console]::ReadKey($true)` for single-key menus (no Enter required)
  - `ESC` always returns to previous menu
  - Every feature end screen shows `[R] Return to menu` and `[0] Exit`
- Cover all error handling scenarios from the PRD table
- End-to-end testing of all navigation flows
- Test cleanup: temp file deletion, scheduled task self-removal

**Definition of Done:**
- All navigation, color, and error-handling conventions are verified. The tool runs cleanly from entry to exit without orphaned temp files or tasks.

---

## Milestone 9: v1.0 Release

**Files:** All

- Final review of all code against PRD spec
- Verify `irm <url> | iex` one-liner works from a clean Windows 10/11 environment
- Tag v1.0 in repository
- Write release notes summarizing all five features

**Definition of Done:**
- Repository tagged `v1.0`. The one-liner install-and-run flow works end-to-end on a fresh Windows 10/11 system.
