param(
    [switch]$RepairSession
)

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
        & (Join-Path $PSScriptRoot "windows10-11\optimize.ps1")
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
