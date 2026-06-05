param(
    [switch]$RepairSession
)

$RepoBaseUrl = "https://raw.githubusercontent.com/souhaibahmed/souhaib-windowsoptimizer/v1.2-iex-support"

# --- Self-heal execution policy (so .ps1 files work on future runs) ---
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser -ErrorAction SilentlyContinue
if ($currentPolicy -eq 'Restricted' -or $currentPolicy -eq 'Undefined') {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue
}

# --- Detect Constrained Language Mode (WDAC/AppLocker lockdown) ---
if ($ExecutionContext.SessionState.LanguageMode -eq 'ConstrainedLanguage') {
    Write-Host "ERROR: Your system restricts PowerShell (Constrained Language Mode)." -ForegroundColor Red
    Write-Host "" -ForegroundColor Yellow
    Write-Host "This is typically enforced by Windows Defender Application Control (WDAC)" -ForegroundColor Yellow
    Write-Host "or AppLocker. Windows Optimizer cannot run under these restrictions." -ForegroundColor Yellow
    Write-Host "" -ForegroundColor Yellow
    Write-Host "To run Windows Optimizer, try one of these:" -ForegroundColor DarkGray
    Write-Host "  1. Run this from an elevated PowerShell prompt (Win+X → Terminal (Admin))" -ForegroundColor Cyan
    Write-Host "  2. Use: powershell -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -ForegroundColor Cyan
    Write-Host "  3. Or bypass CLM via Group Policy (Computer Config → Admin Templates →" -ForegroundColor Cyan
    Write-Host "     Windows Components → Windows Defender Application Control →" -ForegroundColor Cyan
    Write-Host "     'Turn on Virtualization Based Security' → Disabled)" -ForegroundColor Cyan
    exit 1
}

# --- Resolve script root (works both from file and via iex) ---
$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $null }
if (-not $ScriptRoot) {
    Write-Host "Downloading sub-scripts..." -ForegroundColor Yellow
    $ScriptRoot = "$env:TEMP\wo-optimizer"
    $null = New-Item -Path "$ScriptRoot\windows10-11" -ItemType Directory -Force -ErrorAction SilentlyContinue
    try {
        $resp = Invoke-WebRequest -Uri "$RepoBaseUrl/windows10-11/optimize.ps1" -UseBasicParsing -ErrorAction Stop
        $resp.Content | Set-Content -Path "$ScriptRoot\windows10-11\optimize.ps1" -Force
    } catch { Write-Host "✗ Failed to download optimize.ps1: $_" -ForegroundColor Red; exit 1 }
    try {
        $resp = Invoke-WebRequest -Uri "$RepoBaseUrl/library.ps1" -UseBasicParsing -ErrorAction Stop
        $resp.Content | Set-Content -Path "$ScriptRoot\library.ps1" -Force
    } catch { Write-Host "✗ Failed to download library.ps1: $_" -ForegroundColor Red; exit 1 }
    Write-Host "✓ Sub-scripts downloaded" -ForegroundColor Green
}

function Invoke-DependencyCheck {
    param($winVersion)

    # --- Dependency: winget ---
    $wingetAvailable = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)
    if (-not $wingetAvailable) {
        Write-Host "⚠ winget: not available, attempting install..." -ForegroundColor Yellow
        try {
            $appx = Get-AppxPackage -Name "*DesktopAppInstaller*" -ErrorAction SilentlyContinue | Sort-Object -Property Version -Descending | Select-Object -First 1
            if (-not $appx) {
                $appx = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*DesktopAppInstaller*" } | Select-Object -First 1
            }
            if ($appx) {
                Add-AppxPackage -Register "$($appx.InstallLocation)\AppxManifest.xml" -DisableDevelopmentMode -ErrorAction SilentlyContinue
            }
        } catch {
            # winget registration failed, will be retried next session
        }
        $wingetAvailable = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)
        if ($wingetAvailable) {
            Write-Host "✓ winget: installed" -ForegroundColor Green
        } else {
            Write-Host "⚠ winget: not available" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✓ winget: available" -ForegroundColor Green
    }

    # --- Dependency: PSWindowsUpdate ---
    $psWindowsUpdateAvailable = $null -ne (Get-Module -ListAvailable -Name PSWindowsUpdate -ErrorAction SilentlyContinue)
    if (-not $psWindowsUpdateAvailable) {
        Write-Host "⚠ PSWindowsUpdate: not available, attempting install..." -ForegroundColor Yellow
        Install-Module -Name PSWindowsUpdate -Force -ErrorAction SilentlyContinue
        $psWindowsUpdateAvailable = $null -ne (Get-Module -ListAvailable -Name PSWindowsUpdate -ErrorAction SilentlyContinue)
        if ($psWindowsUpdateAvailable) {
            Write-Host "✓ PSWindowsUpdate: installed" -ForegroundColor Green
        } else {
            Write-Host "⚠ PSWindowsUpdate: not available" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✓ PSWindowsUpdate: available" -ForegroundColor Green
    }

    # --- Dependency: GPU Brand ---
    $gpu = Get-WmiObject Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($gpu -and $gpu.Name -match "NVIDIA") {
        $gpuBrand = "NVIDIA"
        Write-Host "✓ GPU: NVIDIA" -ForegroundColor Green
    } elseif ($gpu -and $gpu.Name -match "AMD|Radeon|ATI") {
        $gpuBrand = "AMD"
        Write-Host "✓ GPU: AMD" -ForegroundColor Green
    } elseif ($gpu -and $gpu.Name -match "Intel") {
        $gpuBrand = "INTEL"
        Write-Host "✓ GPU: INTEL" -ForegroundColor Green
    } else {
        $gpuBrand = "UNKNOWN"
        Write-Host "✓ GPU: UNKNOWN" -ForegroundColor Yellow
    }

    # --- Dependency: PowerShell Version ---
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion -lt [Version]"5.1") {
        Write-Host "Warning: PowerShell $psVersion detected. Version 5.1 or higher recommended." -ForegroundColor Yellow
    }

    # --- Write to temp file ---
    $tempContent = @"
WIN_VERSION=$winVersion
WINGET=$(if ($wingetAvailable) { "1" } else { "0" })
GPU=$gpuBrand
PSWindowsUpdate=$(if ($psWindowsUpdateAvailable) { "1" } else { "0" })
SCRIPT_ROOT=$ScriptRoot
"@
    $tempContent | Set-Content -Path "$env:TEMP\wo_session.tmp" -Force

    Write-Host ""
}

# --- Repair Session ---
if ($RepairSession) {
    # --- OS Detection ---
    $osVersion = (Get-WmiObject Win32_OperatingSystem).Version
    $versionParts = $osVersion -split '\.'
    if ($versionParts.Length -ge 2) {
        $major = [int]$versionParts[0]
        $minor = [int]$versionParts[1]
        $build = 0
        if ($versionParts.Length -ge 3) {
            $build = [int]$versionParts[2]
        }

        if ($major -eq 10 -and $minor -eq 0) {
            if ($build -ge 22000) {
                $winVersion = "11"
            } else {
                $winVersion = "10"
            }
        } elseif ($major -eq 6 -and $minor -eq 3) {
            $winVersion = "8"
        } elseif ($major -eq 6 -and $minor -eq 1) {
            $winVersion = "7"
        } else {
            $winVersion = "Unknown"
        }
    } else {
        $winVersion = "Unknown"
    }

    Invoke-DependencyCheck $winVersion
    exit
}

# --- Admin Check ---
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Elevating to Administrator..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# --- Banner ---
Write-Host "Windows Optimizer v1.0" -ForegroundColor Cyan
Write-Host ""

# --- OS Detection ---
$osVersion = (Get-WmiObject Win32_OperatingSystem).Version
$versionParts = $osVersion -split '\.'
if ($versionParts.Length -ge 2) {
    $major = [int]$versionParts[0]
    $minor = [int]$versionParts[1]
    $build = 0
    if ($versionParts.Length -ge 3) {
        $build = [int]$versionParts[2]
    }

    if ($major -eq 10 -and $minor -eq 0) {
        if ($build -ge 22000) {
            $winVersion = "11"
        } else {
            $winVersion = "10"
        }
    } elseif ($major -eq 6 -and $minor -eq 3) {
        $winVersion = "8"
    } elseif ($major -eq 6 -and $minor -eq 1) {
        $winVersion = "7"
    } else {
        $winVersion = "Unknown"
    }
} else {
    $winVersion = "Unknown"
}

Write-Host "Detected OS: Windows $winVersion (Version $osVersion)" -ForegroundColor Green
Write-Host ""

# --- Dependency Checks ---
Invoke-DependencyCheck $winVersion

# --- Scheduled Task (fallback cleanup) ---
$taskName = "WO_Cleanup"
$action = New-ScheduledTaskAction -Execute "powershell" -Argument "-NoProfile -Command `"Remove-Item '$env:TEMP\wo_session.tmp' -ErrorAction SilentlyContinue; Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false -ErrorAction SilentlyContinue`""
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -RunLevel Highest -Force | Out-Null

# --- Routing ---
try {
    if ($winVersion -eq "10" -or $winVersion -eq "11") {
        & (Join-Path $ScriptRoot "windows10-11\optimize.ps1")
    } elseif ($winVersion -eq "8") {
        Write-Host "Windows 8 support coming soon!" -ForegroundColor Yellow
    } elseif ($winVersion -eq "7") {
        Write-Host "Windows 7 support coming soon!" -ForegroundColor Yellow
    } else {
        Write-Host "Unsupported operating system." -ForegroundColor Red
    }
} finally {
    Remove-Item -Path "$env:TEMP\wo_session.tmp" -ErrorAction SilentlyContinue
}
