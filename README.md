<div align="center">

# Windows Optimizer

**PowerShell-based Windows 10/11 optimization suite — Privacy, debloat, app installer, drivers, and performance tweaks. One command, zero bloat.**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-lightgrey)](https://github.com/souhaibahmed/souhaib-windowsoptimizer)
[![PowerShell](https://img.shields.io/badge/powershell-5.1%2B-5391FE)](https://github.com/souhaibahmed/souhaib-windowsoptimizer)

</div>

---

## Quick Start

Run this **one line** in an elevated PowerShell terminal (Win + X → _Terminal (Admin)_):

```powershell
irm https://raw.githubusercontent.com/souhaibahmed/souhaib-windowsoptimizer/main/setup.ps1 | iex
```

That's it. No download, no install, no dependencies to manage. The script auto-elevates if you forgot to run as Administrator, detects your Windows version, checks for `winget` and `PSWindowsUpdate`, and presents an interactive menu — all in under a second.

---

## Menu

```
╔══════════════════════════════════════════╗
║        Windows Optimizer — Gaming PC     ║
╠══════════════════════════════════════════╣
║  [1]  Privacy & Telemetry               ║
║  [2]  Debloat Windows                   ║
║  [3]  Install Apps                      ║
║  [4]  Update Drivers                    ║
║  [5]  Optimize System                   ║
║                                          ║
║  [0]  Exit                              ║
╚══════════════════════════════════════════╝
```

Single-key navigation — no Enter required. Press a number, the feature runs.

---

## Features

### 1. Privacy & Telemetry Hardening

Disables Microsoft data collection, telemetry, and tracking through registry and service modifications:

| Setting | Scope |
|---|---|
| Telemetry (`AllowTelemetry = 0`) | Machine-wide |
| Activity History (feed + publish) | Machine-wide |
| Advertising ID | Per-user |
| App Diagnostics (DiagTrack) | Machine-wide |
| Location Tracking | Machine-wide |
| Cortana | Machine-wide |
| Wi-Fi Sense auto-connect | Machine-wide |
| Feedback requests | Per-user |
| Background apps | Per-user |
| DiagTrack service | Stopped + Disabled |
| `dmwappushservice` | Stopped + Disabled |

Each change logs ✓ or ✗. Summary at the end.

---

### 2. Debloat Windows

Removes pre-installed UWP bloatware packages that serve no productivity or system function:

```
BingWeather, BingNews, BingFinance, BingSports
GetHelp, Getstarted, MicrosoftSolitaireCollection
MicrosoftOfficeHub, OneConnect, People, SkypeApp
Wallet, WindowsFeedbackHub, WindowsMaps
YourPhone, ZuneMusic, ZuneVideo, MixedRealityPortal
```

Also offers to remove **Xbox components** (TCUI, Xbox App, Game Overlay, Identity Provider, Speech-to-Text), **Microsoft Edge**, and **OneDrive** — each with a fallback path if winget uninstall fails.

---

### 3. Install Apps — Interactive Picker

Browse 47 apps across 7 categories in a multi-column terminal picker with keyboard navigation:

| Category | Apps |
|---|---|
| **Browsers** | Brave, Chrome, Chromium, Firefox, Waterfox, Opera, Opera GX, Tor, LibreWolf, Zen |
| **Communication** | Discord, Vencord, Teams, Zoom, Telegram, WhatsApp |
| **Media & Documents** | VLC, K-Lite Codec Pack, Audacity, Spotify, OBS Studio, Adobe Reader |
| **Gaming** | Steam, Epic Games, GOG Galaxy, EA App, Ubisoft Connect, Minecraft, Playnite, PPSSPP |
| **System Monitoring** | MSI Afterburner, HWiNFO, CPU-Z, GPU-Z, CrystalDiskInfo |
| **Utilities** | AnyDesk, TeamViewer, Revo, Everything, WinRAR, 7-Zip, PeaZip, PowerToys, ShareX, LocalSend, IDM + alternatives |
| **Developer Tools** | Python 3, Git, Notepad++, VS Code |

- **Arrow keys** to move cursor
- **Space** to toggle selection (highlighted cyan)
- **I** to install all selected apps in batch via `winget`
- **ESC** to go back
- Auto-detects your **GPU brand** (NVIDIA/AMD/Intel) and surfaces the corresponding driver app

---

### 4. Update Drivers

Two-phase driver update in a single run:

**Phase 1 — Windows & Driver Updates**
Uses `PSWindowsUpdate` to fetch driver and quality updates from Microsoft Update catalog. Checks for required reboot.

**Phase 2 — All-in-One Runtimes**
Installs essential game-ready runtimes via winget:

- Microsoft Visual C++ 2015-2022 (x64 + x86)
- Microsoft DirectX
- .NET Runtime 8.0
- .NET Desktop Runtime 8.0
- Microsoft XNA Framework Redist

---

### 5. Optimize System

Applies 16 performance and UX tweaks in one pass. Shows a preview list first, asks for confirmation ([Y]/[N]), then executes:

| # | Tweak | Method |
|---|---|---|
| 1 | Disable P2P Delivery Optimization | Registry |
| 2 | Set max monitor refresh rate | C# P/Invoke (`EnumDisplaySettings`) |
| 3 | Disable mouse acceleration | Registry + `SystemParametersInfo` |
| 4 | High Performance power plan | `powercfg` |
| 5 | Disable Xbox Game Bar | Registry |
| 6 | Disable startup delay | Registry |
| 7 | Disable hibernation | `powercfg /hibernate off` |
| 8 | Disable sticky keys | Registry |
| 9 | Disable activity history | Registry |
| 10 | Disable location tracking | Registry |
| 11 | Remove widgets from taskbar | Registry + Appx uninstall |
| 12 | Disable Copilot / AI features | Registry + policy |
| 13 | Enable classic context menu | Registry (CLSID) |
| 14 | Disable Bing search in Start | Registry |
| 15 | Enable Ultimate Performance plan | `powercfg` |
| 16 | Enable Windows Sandbox | `Enable-WindowsOptionalFeature` |

Also creates a **System Restore Point** before applying changes.

---

## Requirements

- **Windows 10** (build 10240+) or **Windows 11** (build 22000+)
- **Administrator privileges** (script auto-elevates if not already admin)
- **PowerShell 5.1+** (ships with Windows 10/11)
- Internet connection for winget operations

No external dependencies to pre-install. `winget` and `PSWindowsUpdate` are auto-installed on first run if absent.

---

## Repository Structure

```
windows-optimizer/
├── setup.ps1                     # Entry point — OS detect, dependency check, routing
├── library.ps1                   # App registry (47 apps, 7 categories)
├── windows10-11/
│   └── optimize.ps1              # Gaming branch — all 5 features
├── docs/
│   ├── PRD.md                    # Product Requirements Document
│   ├── RELEASE_NOTES.md          # v1.0 release notes
│   └── ...                       # Additional documentation
└── LICENSE                       # MIT License
```

---

## Design Principles

- **Single-file distribution** — `irm | iex` pattern, no installer, no package manager
- **Zero dependencies to start** — auto-installs winget and PSWindowsUpdate if missing
- **Resilient error handling** — every mutating operation is wrapped in try/catch; a single failure never aborts the full run
- **Original code** — nothing copied from ChrisTitusTech, Windows10Debloater, or any third-party project
- **Clean exit** — temp files removed on exit; fallback scheduled task cleans up on next boot if the process is killed

---

## Error Handling

| Scenario | Behavior |
|---|---|
| winget not found | Auto-install via AppxPackage, retry once, graceful skip |
| PSWindowsUpdate not found | Auto-install via PSGallery, graceful skip |
| Registry write fails | Log ✗, continue to next change |
| App/runtime install fails | Add to failed list, show in end summary |
| Unsupported OS | Print message, exit without changes |
| Temp file lost mid-session | Re-run dependency check inline |

---

## Versioning

| Version | Scope |
|---|---|
| **v1.0** (current) | Windows 10/11, Gaming PC profile, all 5 features |
| **v2.0** (planned) | Office PC branch, Windows 8 support |
| Future | Windows 7 support |

---

## License

[MIT](LICENSE) © 2026 Souhaib

---

<div align="center">
  
**Windows Optimizer** — Because Windows is what you make of it.

</div>
