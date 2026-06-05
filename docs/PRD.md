# Windows Optimizer — PRD

## Summary

PowerShell-based Windows optimization tool distributed via `irm <url> | iex`. Runs entirely inside the PowerShell terminal with no GUI. Detects the OS version and dependencies on launch, stores results in a temp file, then routes the user to the correct branch. v1.0 targets Windows 10/11, Gaming profile only. The tool covers privacy hardening, debloating, app installation via a library-driven picker, driver updates, and a bundled performance optimization routine. All code is original — no copying from referenced projects.

**Execution policy handling:** On first run, the script auto-sets `RemoteSigned` for `CurrentUser` scope so subsequent runs work without manual policy changes. Detects Constrained Language Mode (WDAC/AppLocker) and prints a clear error with workarounds if present.

---

## Repository Structure

```
windows-optimizer/
├── setup.ps1                  # Entry point. OS detect, dependency check, routing.
├── library.ps1                # App registry. All scripts source from here.
└── windows10-11/
    └── optimize.ps1           # Gaming branch. All features live here.
```

---

## Entry Point — `setup.ps1`

### Responsibilities

1. Self-heal execution policy (`Set-ExecutionPolicy RemoteSigned` for `CurrentUser`)
2. Detect Constrained Language Mode (WDAC/AppLocker) and abort with workaround instructions
3. Detect Windows version via `(Get-WmiObject Win32_OperatingSystem).Version`
4. Check and auto-install dependencies
5. Store results in temp file
6. Route user to the correct branch script
7. Register cleanup task on exit and shutdown/restart

### Dependency Checks

| Dependency | Check | Action if missing |
|---|---|---|
| `winget` | `Get-Command winget` | Auto-install via `Add-AppxPackage` (Microsoft.DesktopAppInstaller) |
| GPU brand | `Get-WmiObject Win32_VideoController` | Detect NVIDIA / AMD / Intel, store result |
| PowerShell version | `$PSVersionTable.PSVersion` | Warn if below 5.1 |

### Temp File

- Path: `$env:TEMP\wo_session.tmp`
- Format: key=value plain text
- Contents:
  ```
  WIN_VERSION=10|11
  WINGET=1|0
  GPU=NVIDIA|AMD|INTEL|UNKNOWN
  ```
- Deletion:
  - Explicit: `Remove-Item` at script exit (all paths including user-initiated exit)
  - Fallback: Register a one-time scheduled task at startup named `WO_Cleanup` that deletes the file on next boot, then self-deletes the task

### Routing Logic

```
Windows 10 / 11  →  .\windows10-11\optimize.ps1
Windows 8        →  "Coming soon" message → exit
Windows 7        →  "Coming soon" message → exit
Other/Unknown    →  "Unsupported OS" message → exit
```

---

## App Registry — `library.ps1`

- Single source of truth for all installable apps
- Called by `optimize.ps1` when the user enters the app installer
- Structure: hashtable of categories, each containing app objects

### Schema

```powershell
$AppLibrary = @{
    "Gaming" = @(
        @{ Name = "Steam";       ID = "Valve.Steam" },
        @{ Name = "Epic Games";  ID = "EpicGames.EpicGamesLauncher" }
    )
    "Browsers" = @(
        @{ Name = "Firefox";     ID = "Mozilla.Firefox" },
        @{ Name = "Zen Browser"; ID = "Zen-Team.Zen-Browser" },
        @{ Name = "Chrome";      ID = "Google.Chrome" }
    )
    "Programming" = @(
        @{ Name = "Python";          ID = "Python.Python.3" },
        @{ Name = "Java (JDK)";      ID = "Oracle.JDK.21" },
        @{ Name = "Visual Studio";   ID = "Microsoft.VisualStudio.2022.Community" }
    )
)
```

- To add an app: add one line to the correct category array
- No other file needs to change

---

## Gaming Branch — `optimize.ps1`

### Main Menu

Displayed after routing. Single-keypress selection via `[Console]::ReadKey($true)`. No Enter required.

```
Windows Optimizer — Gaming PC

  [1]  Privacy & Telemetry
  [2]  Debloat Windows
  [3]  Install Apps
  [4]  Update Drivers
  [5]  Optimize System
  [0]  Exit

Select an option:
```

---

### Feature 1 — Privacy & Telemetry

Applies registry and policy changes to disable Microsoft data collection. All changes made via `Set-ItemProperty` and `reg add`. No external scripts used.

**Actions:**

- Disable telemetry: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection` → `AllowTelemetry = 0`
- Disable activity history: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\System` → `EnableActivityFeed = 0`, `PublishUserActivities = 0`
- Disable advertising ID: `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo` → `Enabled = 0`
- Disable app diagnostics: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack` → `DiagTrackAuthorization = 0`
- Disable location tracking: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location` → `Value = Deny`
- Disable Cortana: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search` → `AllowCortana = 0`
- Disable Wi-Fi Sense: `HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config` → `AutoConnectAllowedOEM = 0`
- Disable feedback requests: `HKCU:\SOFTWARE\Microsoft\Siuf\Rules` → `NumberOfSIUFInPeriod = 0`
- Disable background apps: `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications` → `GlobalUserDisabled = 1`
- Stop and disable DiagTrack service: `Stop-Service "DiagTrack"` + `Set-Service "DiagTrack" -StartupType Disabled`
- Stop and disable dmwappushservice: same pattern

**Output:** Line-by-line status as each change applies. Summary at end.

---

### Feature 2 — Debloat Windows

Removes pre-installed UWP apps that serve no productivity or system function. Uses `Get-AppxPackage` and `Remove-AppxPackage`. Original curated list — no external scripts.

**Apps targeted for removal (pattern matches):**

```
Microsoft.BingWeather
Microsoft.BingNews
Microsoft.BingFinance
Microsoft.BingSports
Microsoft.GetHelp
Microsoft.Getstarted
Microsoft.MicrosoftSolitaireCollection
Microsoft.MicrosoftOfficeHub
Microsoft.OneConnect
Microsoft.People
Microsoft.SkypeApp
Microsoft.Wallet
Microsoft.WindowsFeedbackHub
Microsoft.WindowsMaps
Microsoft.Xbox.TCUI
Microsoft.XboxApp
Microsoft.XboxGameOverlay
Microsoft.XboxGamingOverlay
Microsoft.XboxIdentityProvider
Microsoft.XboxSpeechToTextOverlay
Microsoft.YourPhone
Microsoft.ZuneMusic
Microsoft.ZuneVideo
Microsoft.MixedReality.Portal
```

**Process:**
- For each package: attempt removal, catch errors silently, log pass/fail
- At end: show count of removed vs failed

---

### Feature 3 — Install Apps

Calls `library.ps1`, renders interactive picker, builds install queue, runs installs.

#### Picker UI

- Categories rendered in columns (2–3 per row), auto-calculated from terminal width: `[Console]::WindowWidth`
- Each app shows a toggle box: `[ ]` unselected → `[x]` selected (color change: default → Cyan)
- Navigation: Arrow keys move cursor. Spacebar toggles selection. `I` key triggers install. `ESC` returns to main menu.

#### Rendering Logic

```
┌─ Gaming ─────────────┐  ┌─ Browsers ───────────┐  ┌─ Programming ────────┐
│ [ ] Steam            │  │ [ ] Firefox           │  │ [ ] Python           │
│ [ ] Epic Games       │  │ [ ] Zen Browser       │  │ [ ] Java (JDK)       │
│                      │  │ [ ] Chrome            │  │ [ ] Visual Studio    │
└──────────────────────┘  └──────────────────────┘  └──────────────────────┘

[SPACE] Toggle   [I] Install   [ESC] Back
```

- Cursor position tracked via `$cursorRow` / `$cursorCol` indices into a flattened app array
- Selected apps collected into `$installQueue = @()`

#### GPU App Injection

Before rendering picker, read `$env:TEMP\wo_session.tmp`:
- If `GPU=NVIDIA` → inject `@{ Name = "NVIDIA App"; ID = "Nvidia.NVIDIAapp" }` into a "System" category
- If `GPU=AMD` → inject `@{ Name = "AMD Software: Adrenalin"; ID = "AdvancedMicroDevices.AMDSoftwareAdrenalinEdition" }`
- If `GPU=INTEL` → inject `@{ Name = "Intel Arc Control"; ID = "Intel.ArcControl" }`

#### Install Process

```powershell
foreach ($app in $installQueue) {
    Write-Host "Installing $($app.Name)..."
    $result = winget install --id $app.ID --silent --accept-package-agreements --accept-source-agreements 2>&1
    if ($LASTEXITCODE -eq 0) {
        $succeeded += $app.Name
    } else {
        $failed += $app.Name
    }
}
```

**End screen:**
```
Install complete.

✓ Installed (4):  Steam, Firefox, Python, NVIDIA App
✗ Failed    (1):  Visual Studio

[R] Return to menu   [0] Exit
```

---

### Feature 4 — Update Drivers

Install gaming runtimes via winget. Targets:

```
Microsoft.VCRedist.2015+.x64
Microsoft.VCRedist.2015+.x86
Microsoft.DirectX
Microsoft.DotNet.Runtime.8
Microsoft.DotNet.DesktopRuntime.8
Microsoft.XNARedist
```

Same skip-and-log error model as app installer.

---

### Feature 5 — Optimize System

Bundled performance and UX improvements applied sequentially. Single keypress to confirm before running: `[Y] Apply all  [N] Cancel`

**Actions:**

#### Delivery Optimization (disable P2P upload)
```
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config
→ DODownloadMode = 0
```

#### Refresh Rate (set to maximum)
```powershell
$display = Get-CimInstance -Namespace root/wmi -ClassName WmiMonitorListedSupportedSourceModes
$maxRate = ($display.MonitorSourceModes | Sort-Object -Property VSyncFrequencyDivider | Select-Object -Last 1).VSyncFrequencyDivider
# Apply via ChangeDisplaySettings with DEVMODE struct via P/Invoke
```

#### Mouse Acceleration (disable)
```
HKCU:\Control Panel\Mouse
→ MouseSpeed = 0
→ MouseThreshold1 = 0
→ MouseThreshold2 = 0
```
Also call `SystemParametersInfo` via P/Invoke with `SPI_SETMOUSE` to apply without reboot.

#### Power Plan (set to High Performance)
```powershell
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
```

#### Visual Effects (performance mode)
```
HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects
→ VisualFXSetting = 2
```

#### Disable Xbox Game Bar
```
HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR → AppCaptureEnabled = 0
HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR → AllowGameDVR = 0
```

#### Disable Startup Delay
```
HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize
→ StartupDelayInMSec = 0
```

#### Disable Hibernation
```powershell
powercfg /hibernate off
```

**Output:** Line-by-line status per action. Summary at end.

---

## UX Conventions (Global)

- **Color scheme:** Default terminal colors. Highlighted cursor: `Cyan`. Success: `Green`. Failure: `Red`. Warnings: `Yellow`.
- **No Enter required** for single-option menus (`[Console]::ReadKey($true)`)
- **Enter required** only for multi-select confirmation (`[I]` key in app picker)
- **Back navigation:** `ESC` always returns to the previous menu
- **Post-feature:** Always show `[R] Return to menu` and `[0] Exit` after any feature completes
- **Admin check:** `setup.ps1` verifies it is running as Administrator on launch. If not: re-launches self elevated via `Start-Process powershell -Verb RunAs`

---

## Error Handling

| Scenario | Behavior |
|---|---|
| winget not found | Auto-install, retry once, abort app features if still missing |
| Registry key write fails | Log failure, continue to next action |
| App install fails | Skip, add to failed list, show in summary |
| Runtime install fails | Skip, add to failed list, show in summary |
| Temp file not found mid-session | Re-run dependency check inline, recreate file |
| Unsupported OS | Exit with message, no changes applied |
| Execution policy blocks script | Auto-heal via `Set-ExecutionPolicy RemoteSigned` at startup |
| Constrained Language Mode (WDAC/AppLocker) | Exit with error message listing workarounds |

---

## Versioning Plan

| Version | Scope |
|---|---|
| v1.0 | Windows 10/11, Gaming branch, all 5 features above |
| v2.0 | Office PC branch, Windows 8 support |
| Future | Windows 7 support |

---

## Out of Scope (v1.0)

- GUI or web interface
- Remote/multi-machine execution
- Automatic scheduled re-runs
- Office PC profile
- Undo / restore point creation (user's responsibility)
