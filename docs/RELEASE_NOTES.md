# Release Notes — Windows Optimizer v1.0

**Release date:** May 26, 2026

## Installation

Run the following command in an elevated **PowerShell** window:

```powershell
irm https://raw.githubusercontent.com/baqir/Windows-optimizer/main/setup.ps1 | iex
```

> If your system blocks `.ps1` files (default `Restricted` policy), paste this into **any** terminal (cmd.exe or PowerShell):
> ```
> powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/baqir/Windows-optimizer/main/setup.ps1 | iex"
> ```

## Overview

Windows Optimizer is a PowerShell-based utility that streamlines the configuration of Windows 10 and Windows 11 systems. It consolidates common optimization, privacy, and maintenance tasks into a single interactive terminal menu with no external dependencies beyond what Windows ships by default.

## Features

1. **Privacy and Telemetry Hardening** — Disables telemetry, Cortana, activity history, advertising ID, location tracking, background apps, and Wi-Fi Sense through registry and service modifications.

2. **Debloat Windows** — Removes pre-installed bloatware packages (Bing apps, Xbox components, Skype, OneConnect, Zune, Mixed Reality Portal, and others) via `Remove-AppxPackage`.

3. **Install Apps** — Interactive multi-column menu for batch-installing applications through winget. Supports Gaming, Browsers, Programming, and System categories. Automatically detects the GPU brand and surfaces the corresponding vendor software (NVIDIA App, AMD Adrenalin, or Intel Arc Control).

4. **Update Drivers** — Installs essential runtimes (VC++ redistributables, DirectX, .NET 8.0, XNA Framework) through winget.

5. **Optimize System** — Applies eight performance tweaks in one pass: disables P2P Delivery Optimization, sets maximum monitor refresh rate, disables mouse acceleration, enables High Performance power plan, switches visual effects to performance mode, disables Xbox Game Bar, removes startup delay, and disables hibernation.

## Requirements

- Windows 10 or Windows 11
- Administrator privileges (the script auto-elevates if not already running as Administrator)

## Important Notes

- The user is solely responsible for creating a system restore point before running any feature. Windows Optimizer does not automatically create restore points.
- This code is original. It was not copied from ChrisTitusTech, the Windows 10 Debloater project, or any similar third-party repository.
- A temporary scheduled task (`WO_Cleanup`) is registered during execution to clean up session artifacts on next boot.
