<#
.SYNOPSIS
    Windows Optimizer — Gaming PC Main Menu
.DESCRIPTION
    Main menu stub for the gaming branch of Windows Optimizer.
    Invoked by setup.ps1 after routing a Windows 10/11 user to the gaming branch.
#>

function Invoke-PrivacyTelemetry {
    Clear-Host
    Write-Host "=== Privacy & Telemetry Hardening ===" -ForegroundColor Cyan
    Write-Host ""

    $succeeded = 0
    $failed = 0

    $registryChanges = @(
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "AllowTelemetry"; Value = 0; Type = "DWord"; Desc = "Disable telemetry" }
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name = "EnableActivityFeed"; Value = 0; Type = "DWord"; Desc = "Disable activity history (feed)" }
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name = "PublishUserActivities"; Value = 0; Type = "DWord"; Desc = "Disable activity history (publishing)" }
        @{ Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; Name = "Enabled"; Value = 0; Type = "DWord"; Desc = "Disable advertising ID" }
        @{ Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack"; Name = "DiagTrackAuthorization"; Value = 0; Type = "DWord"; Desc = "Disable app diagnostics" }
        @{ Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"; Name = "Value"; Value = "Deny"; Type = "String"; Desc = "Disable location tracking" }
        @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name = "AllowCortana"; Value = 0; Type = "DWord"; Desc = "Disable Cortana" }
        @{ Path = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"; Name = "AutoConnectAllowedOEM"; Value = 0; Type = "DWord"; Desc = "Disable Wi-Fi Sense" }
        @{ Path = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"; Name = "NumberOfSIUFInPeriod"; Value = 0; Type = "DWord"; Desc = "Disable feedback requests" }
        @{ Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"; Name = "GlobalUserDisabled"; Value = 1; Type = "DWord"; Desc = "Disable background apps" }
    )

    foreach ($change in $registryChanges) {
        try {
            $parent = Split-Path $change.Path -Parent
            if (-not (Test-Path $change.Path)) {
                New-Item -Path $change.Path -Force -ErrorAction Stop | Out-Null
            }
            if ($change.Type -eq "DWord") {
                Set-ItemProperty -Path $change.Path -Name $change.Name -Value ([int]$change.Value) -Type DWord -ErrorAction Stop
            } else {
                Set-ItemProperty -Path $change.Path -Name $change.Name -Value $change.Value -ErrorAction Stop
            }
            Write-Host "  ✓ $($change.Desc)" -ForegroundColor Green
            $succeeded++
        } catch {
            Write-Host "  ✗ $($change.Desc)" -ForegroundColor Red
            $failed++
        }
    }

    $services = @(
        @{ Name = "DiagTrack"; Desc = "Stop and disable DiagTrack (Telemetry)" }
        @{ Name = "dmwappushservice"; Desc = "Stop and disable dmwappushservice" }
    )

    foreach ($svc in $services) {
        try {
            Stop-Service $svc.Name -Force -ErrorAction Stop
            Set-Service $svc.Name -StartupType Disabled -ErrorAction Stop
            Write-Host "  ✓ $($svc.Desc)" -ForegroundColor Green
            $succeeded++
        } catch {
            Write-Host "  ✗ $($svc.Desc)" -ForegroundColor Red
            $failed++
        }
    }

    Write-Host ""
    if ($failed -eq 0) {
        Write-Host "Summary: $succeeded applied, all successful!" -ForegroundColor Green
    } else {
        Write-Host "Summary: $succeeded applied, $failed failed" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "[R] Return to menu   [0] Exit" -ForegroundColor DarkGray
    Write-Host ""

    do {
        $key = [Console]::ReadKey($true).Key
        if ($key -eq "R" -or $key -eq "Escape") { return }
        if ($key -eq "D0" -or $key -eq "NumPad0") {
            Clear-Host
            Write-Host "Exiting Windows Optimizer. Goodbye!" -ForegroundColor Green
            exit
        }
    } while ($true)
}

function Invoke-DebloatWindows {
    Clear-Host
    Write-Host "=== Debloat Windows ===" -ForegroundColor Cyan
    Write-Host ""

    $packages = @(
        "Microsoft.BingWeather"
        "Microsoft.BingNews"
        "Microsoft.BingFinance"
        "Microsoft.BingSports"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.YourPhone"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "Microsoft.MixedReality.Portal"
    )

    $xboxPackages = @(
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
    )

    $removed = 0
    $failed = 0

    foreach ($packageName in $packages) {
        try {
            $appx = Get-AppxPackage -Name "$packageName*" -ErrorAction SilentlyContinue
            if ($appx) {
                Remove-AppxPackage -Package $appx -ErrorAction Stop
                Write-Host "  ✓ Removed: $packageName" -ForegroundColor Green
                $removed++
            } else {
                Write-Host "  - Not installed: $packageName" -ForegroundColor DarkGray
            }
        } catch {
            Write-Host "  ✗ Failed: $packageName" -ForegroundColor Red
            $failed++
        }
    }

    Write-Host ""
    Write-Host "Do you want to remove Xbox components? [Y]es [N]o" -ForegroundColor Yellow
    $key = [Console]::ReadKey($true).Key
    if ($key -eq "Y") {
        foreach ($packageName in $xboxPackages) {
            try {
                $appx = Get-AppxPackage -Name "$packageName*" -ErrorAction SilentlyContinue
                if ($appx) {
                    Remove-AppxPackage -Package $appx -ErrorAction Stop
                    Write-Host "  ✓ Removed: $packageName" -ForegroundColor Green
                    $removed++
                } else {
                    Write-Host "  - Not installed: $packageName" -ForegroundColor DarkGray
                }
            } catch {
                Write-Host "  ✗ Failed: $packageName" -ForegroundColor Red
                $failed++
            }
        }
    }

    Write-Host ""
    Write-Host "Removing Microsoft Edge..." -ForegroundColor Yellow
    $edgeResult = winget uninstall "Microsoft Edge" --silent 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Removed: Microsoft Edge" -ForegroundColor Green
        $removed++
    } else {
        try {
            Start-Process -FilePath "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe" -ArgumentList "--uninstall --system-level --force-uninstall" -Wait -NoNewWindow
            Write-Host "  ✓ Removed: Microsoft Edge" -ForegroundColor Green
            $removed++
        } catch {
            Write-Host "  ✗ Failed: Microsoft Edge" -ForegroundColor Red
            $failed++
        }
    }

    Write-Host ""
    Write-Host "Removing Microsoft OneDrive..." -ForegroundColor Yellow
    $onedriveResult = winget uninstall "Microsoft OneDrive" --silent 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Removed: Microsoft OneDrive" -ForegroundColor Green
        $removed++
    } else {
        try {
            Start-Process -FilePath "$env:SystemRoot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow
            Write-Host "  ✓ Removed: Microsoft OneDrive" -ForegroundColor Green
            $removed++
        } catch {
            Write-Host "  ✗ Failed: Microsoft OneDrive" -ForegroundColor Red
            $failed++
        }
    }

    Write-Host ""
    if ($failed -eq 0) {
        Write-Host "Summary: $removed removed, $failed failed" -ForegroundColor Green
    } else {
        Write-Host "Summary: $removed removed, $failed failed" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "[R] Return to menu   [0] Exit" -ForegroundColor DarkGray
    Write-Host ""

    do {
        $key = [Console]::ReadKey($true).Key
        if ($key -eq "R" -or $key -eq "Escape") { return }
        if ($key -eq "D0" -or $key -eq "NumPad0") {
            Clear-Host
            Write-Host "Exiting Windows Optimizer. Goodbye!" -ForegroundColor Green
            exit
        }
    } while ($true)
}

function Invoke-AppInstaller {
    Clear-Host

    # --- 1. Load library ---
    $optimizeScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $null }
    if (-not $optimizeScriptRoot) {
        $tempFile = "$env:TEMP\wo_session.tmp"
        if (Test-Path $tempFile) {
            $tempContent = Get-Content $tempFile -Raw -ErrorAction SilentlyContinue
            if ($tempContent -match "SCRIPT_ROOT=(.+)") {
                $optimizeScriptRoot = Join-Path $Matches[1].Trim() "windows10-11"
            }
        }
    }
    $libPath = Join-Path $optimizeScriptRoot "..\library.ps1"
    if (-not (Test-Path $libPath)) {
        $libPath = ".\library.ps1"
    }
    . $libPath

    # --- 2. GPU app injection ---
    $tempFile = "$env:TEMP\wo_session.tmp"
    if (-not (Test-Path $tempFile)) {
        $null = Invoke-DependencyCheck (Get-WmiObject Win32_OperatingSystem).Version 2>&1
    }
    $gpuBrand = "UNKNOWN"
    if (Test-Path $tempFile) {
        $content = Get-Content $tempFile -Raw -ErrorAction SilentlyContinue
        if ($content -match "GPU=(.+)") {
            $gpuBrand = $Matches[1].Trim()
        }
    }

    switch ($gpuBrand) {
        "NVIDIA" {
            if (-not $AppLibrary.ContainsKey("System")) {
                $AppLibrary["System"] = @()
            }
            $AppLibrary["System"] += @{ Name = "NVIDIA App"; ID = "Nvidia.NVIDIAapp" }
        }
        "AMD" {
            if (-not $AppLibrary.ContainsKey("System")) {
                $AppLibrary["System"] = @()
            }
            $AppLibrary["System"] += @{ Name = "AMD Software: Adrenalin"; ID = "AdvancedMicroDevices.AMDSoftwareAdrenalinEdition" }
        }
        "INTEL" {
            if (-not $AppLibrary.ContainsKey("System")) {
                $AppLibrary["System"] = @()
            }
            $AppLibrary["System"] += @{ Name = "Intel Arc Control"; ID = "Intel.ArcControl" }
        }
    }

    # --- 3. Check winget availability ---
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "⚠ winget is not available. Skipping app installation." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "[R] Return to menu   [0] Exit" -ForegroundColor DarkGray
        Write-Host ""
        do {
            $key = [Console]::ReadKey($true).Key
            if ($key -eq "R" -or $key -eq "Escape") { return }
            if ($key -eq "D0" -or $key -eq "NumPad0") {
                Clear-Host
                Write-Host "Exiting Windows Optimizer. Goodbye!" -ForegroundColor Green
                exit
            }
        } while ($true)
    }

    # --- 4. Build ordered category list ---
    $categoryOrder = @()
    foreach ($cat in @("System", "Gaming", "Browsers", "Communication", "Media & Documents", "System Monitoring", "Utilities", "Developer Tools")) {
        if ($AppLibrary.ContainsKey($cat) -and $AppLibrary[$cat].Count -gt 0) {
            $categoryOrder += $cat
        }
    }
    foreach ($cat in $AppLibrary.Keys) {
        if ($categoryOrder -notcontains $cat -and $AppLibrary[$cat].Count -gt 0) {
            $categoryOrder += $cat
        }
    }

    # --- 4. Calculate layout ---
    $boxWidths = @{}
    foreach ($cat in $categoryOrder) {
        $maxAppLen = 0
        foreach ($app in $AppLibrary[$cat]) {
            if ($app.Name.Length -gt $maxAppLen) { $maxAppLen = $app.Name.Length }
        }
        $appLineLen = $maxAppLen + 5
        $catLineLen = $cat.Length + 4
        $innerWidth = [Math]::Max($appLineLen, $catLineLen)
        $boxWidths[$cat] = $innerWidth + 2
    }

    $termWidth = [Console]::WindowWidth
    $numCategories = $categoryOrder.Count
    $maxBoxWidth = if ($boxWidths.Values.Count -gt 0) { ($boxWidths.Values | Measure-Object -Maximum).Maximum } else { 20 }
    $numCols = [Math]::Min($numCategories, [Math]::Max(2, [Math]::Floor(($termWidth - 4) / ([Math]::Max($maxBoxWidth, 20) + 3))))
    if ($numCols -lt 1) { $numCols = 1 }

    # --- 5. Selection state ---
    $selected = @{}

    function Get-MaxRows($cats, $apps) {
        $max = 0
        foreach ($cat in $cats) { if ($apps[$cat].Count -gt $max) { $max = $apps[$cat].Count } }
        return $max
    }

    # --- 6. Interactive loop ---
    $cursorCol = 0
    $cursorRow = 0
    $installTriggered = $false
    $pressedKey = $null

    while (-not $installTriggered) {
        Clear-Host
        Write-Host "=== Install Apps ===" -ForegroundColor Cyan
        Write-Host ""

        $maxRows = Get-MaxRows $categoryOrder $AppLibrary

        $boxLines = @{}
        foreach ($cat in $categoryOrder) {
            $catIdx = [array]::IndexOf($categoryOrder, $cat)
            $bw = $boxWidths[$cat]
            $innerWidth = $bw - 2
            $apps = $AppLibrary[$cat]
            $lines = @()

            $dashCount = $innerWidth - $cat.Length - 2
            if ($dashCount -lt 1) { $dashCount = 1 }
            $lines += "┌─$cat" + "─" * $dashCount + "┐"

            for ($r = 0; $r -lt $maxRows; $r++) {
                if ($r -lt $apps.Count) {
                    $app = $apps[$r]
                    $key = "$catIdx,$r"
                    $isSel = $selected.ContainsKey($key) -and $selected[$key]
                    $toggle = if ($isSel) { "[x]" } else { "[ ]" }
                    $appLine = " $toggle $($app.Name)".PadRight($innerWidth, ' ')
                    $lines += "│$appLine│"
                } else {
                    $lines += "│" + (" " * $innerWidth) + "│"
                }
            }

            $lines += "└" + ("─" * $innerWidth) + "┘"

            $boxLines[$cat] = $lines
        }

        $linesPerBox = $maxRows + 2

        for ($row = 0; $row -lt $linesPerBox; $row++) {
            for ($c = 0; $c -lt $numCols; $c++) {
                $cat = $categoryOrder[$c]
                $catLines = $boxLines[$cat]
                $line = $catLines[$row]

                $isCursorBox = ($c -eq $cursorCol)
                $isAppRow = ($row -ge 1 -and $row -le $AppLibrary[$cat].Count)
                $isCursorRow = ($isCursorBox -and $isAppRow -and ($row - 1) -eq $cursorRow)

                if ($isCursorRow) {
                    Write-Host $line -ForegroundColor Cyan -NoNewline
                } elseif ($row -eq 0 -or $row -eq ($linesPerBox - 1)) {
                    Write-Host $line -ForegroundColor DarkGray -NoNewline
                } else {
                    $appIdx = $row - 1
                    $key = "$c,$appIdx"
                    $isSelected = $selected.ContainsKey($key) -and $selected[$key]
                    if ($isSelected) {
                        Write-Host $line -ForegroundColor Cyan -NoNewline
                    } else {
                        Write-Host $line -ForegroundColor Gray -NoNewline
                    }
                }

                if ($c -lt $numCols - 1) {
                    Write-Host "  " -NoNewline
                }
            }
            Write-Host ""
        }

        Write-Host ""
        Write-Host "[SPACE] Toggle   [I] Install   [ESC] Back" -ForegroundColor DarkGray

        $keyInfo = [Console]::ReadKey($true)
        $pressedKey = $keyInfo.Key

        switch ($keyInfo.Key) {
            "LeftArrow" {
                if ($cursorCol -gt 0) { $cursorCol-- }
                $cat = $categoryOrder[$cursorCol]
                if ($cursorRow -ge $AppLibrary[$cat].Count) { $cursorRow = $AppLibrary[$cat].Count - 1 }
                if ($cursorRow -lt 0) { $cursorRow = 0 }
            }
            "RightArrow" {
                if ($cursorCol -lt $numCategories - 1) { $cursorCol++ }
                $cat = $categoryOrder[$cursorCol]
                if ($cursorRow -ge $AppLibrary[$cat].Count) { $cursorRow = $AppLibrary[$cat].Count - 1 }
                if ($cursorRow -lt 0) { $cursorRow = 0 }
            }
            "UpArrow" {
                if ($cursorRow -gt 0) { $cursorRow-- }
            }
            "DownArrow" {
                $cat = $categoryOrder[$cursorCol]
                if ($cursorRow -lt $AppLibrary[$cat].Count - 1) { $cursorRow++ }
            }
            "Spacebar" {
                $key = "$cursorCol,$cursorRow"
                if ($selected.ContainsKey($key) -and $selected[$key]) {
                    $selected[$key] = $false
                } else {
                    $selected[$key] = $true
                }
            }
            "I" {
                $anySelected = ($selected.Values | Where-Object { $_ }).Count -gt 0
                if ($anySelected) {
                    $installTriggered = $true
                }
            }
            "Escape" {
                return
            }
        }
    }

    # --- 7. Build install queue ---
    $installQueue = @()
    for ($c = 0; $c -lt $numCategories; $c++) {
        $cat = $categoryOrder[$c]
        $apps = $AppLibrary[$cat]
        for ($r = 0; $r -lt $apps.Count; $r++) {
            $key = "$c,$r"
            if ($selected.ContainsKey($key) -and $selected[$key]) {
                $installQueue += $apps[$r]
            }
        }
    }

    # --- 8. Install loop ---
    Clear-Host
    Write-Host "=== Installing Apps ===" -ForegroundColor Cyan
    Write-Host ""

    $succeeded = @()
    $failed = @()

    foreach ($app in $installQueue) {
        Write-Host "Installing $($app.Name)..." -NoNewline
        $result = winget install --id $app.ID --silent --accept-package-agreements --accept-source-agreements 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host " Done" -ForegroundColor Green
            $succeeded += $app.Name
        } else {
            Write-Host " Failed" -ForegroundColor Red
            $failed += $app.Name
        }
    }

    # --- 9. End screen ---
    Clear-Host
    Write-Host "=== Install Complete ===" -ForegroundColor Cyan
    Write-Host ""

    if ($succeeded.Count -gt 0) {
        Write-Host "✓ Installed ($($succeeded.Count)): $($succeeded -join ', ')" -ForegroundColor Green
    }
    if ($failed.Count -gt 0) {
        Write-Host "✗ Failed ($($failed.Count)): $($failed -join ', ')" -ForegroundColor Red
    }
    if ($succeeded.Count -eq 0 -and $failed.Count -eq 0) {
        Write-Host "No apps were selected for installation." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "[R] Return to menu   [0] Exit" -ForegroundColor DarkGray
    Write-Host ""

    do {
        $key = [Console]::ReadKey($true).Key
        if ($key -eq "R" -or $key -eq "Escape") { return }
        if ($key -eq "D0" -or $key -eq "NumPad0") {
            Clear-Host
            Write-Host "Exiting Windows Optimizer. Goodbye!" -ForegroundColor Green
            exit
        }
    } while ($true)
}

function Invoke-UpdateDrivers {
    Clear-Host
    Write-Host "=== Update Drivers ===" -ForegroundColor Cyan
    Write-Host ""

    # --- Phase 1: Windows & Driver Updates ---
    Write-Host "Phase 1 — Windows & Driver Updates" -ForegroundColor Cyan
    Write-Host ""

    $tempFile = "$env:TEMP\wo_session.tmp"
    if (-not (Test-Path $tempFile)) {
        $null = Invoke-DependencyCheck (Get-WmiObject Win32_OperatingSystem).Version 2>&1
    }
    $pswuEnabled = $false
    if (Test-Path $tempFile) {
        $content = Get-Content $tempFile -Raw -ErrorAction SilentlyContinue
        if ($content -match "PSWindowsUpdate=1") {
            $pswuEnabled = $true
        }
    }

    if (-not $pswuEnabled) {
        Write-Host "  ⚠ PSWindowsUpdate module not requested. Skipping Windows Update and driver updates." -ForegroundColor Yellow
    } else {
        try {
            Import-Module PSWindowsUpdate -ErrorAction Stop

            # Install all Windows updates (quality, security, etc.)
            Write-Host "  Installing Windows updates..." -ForegroundColor DarkGray
            $wuUpdates = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot -ErrorAction Stop

            # Install driver updates
            Write-Host "  Installing driver updates..." -ForegroundColor DarkGray
            $driverUpdates = Get-WindowsUpdate -UpdateType Driver -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot -ErrorAction Stop

            Write-Host "  ✓ Windows Update and driver check complete" -ForegroundColor Green

            $needsReboot = $false
            $allUpdates = @()
            if ($wuUpdates) { $allUpdates += $wuUpdates }
            if ($driverUpdates) { $allUpdates += $driverUpdates }
            foreach ($u in $allUpdates) {
                if ($u.RebootRequired) { $needsReboot = $true; break }
            }

            if ($needsReboot) {
                Write-Host "  ⚠ A reboot is required to complete installation." -ForegroundColor Yellow
                Write-Host "    Please reboot your system at your convenience." -ForegroundColor DarkGray
            }
        } catch {
            Write-Host "  ✗ Windows Update phase failed: $_" -ForegroundColor Red
        }
    }

    Write-Host ""

    # --- Phase 2: All-in-One Runtimes ---
    Write-Host "Phase 2 — All-in-One Runtimes" -ForegroundColor Cyan
    Write-Host ""

    $runtimes = @(
        @{ Name = "Microsoft Visual C++ 2015-2022 x64"; ID = "Microsoft.VCRedist.2015+.x64" }
        @{ Name = "Microsoft Visual C++ 2015-2022 x86"; ID = "Microsoft.VCRedist.2015+.x86" }
        @{ Name = "Microsoft DirectX"; ID = "Microsoft.DirectX" }
        @{ Name = ".NET Runtime 8.0"; ID = "Microsoft.DotNet.Runtime.8" }
        @{ Name = ".NET Desktop Runtime 8.0"; ID = "Microsoft.DotNet.DesktopRuntime.8" }
        @{ Name = "Microsoft XNA Framework Redist"; ID = "Microsoft.XNARedist" }
    )

    # --- Check winget availability for Phase 2 ---
    $wingetAvailable = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)
    if (-not $wingetAvailable) {
        Write-Host "⚠ winget is not available. Skipping runtime installation." -ForegroundColor Yellow
    }

    $succeeded = @()
    $failed = @()

    if ($wingetAvailable) {
        foreach ($runtime in $runtimes) {
            Write-Host "Installing $($runtime.Name)..." -NoNewline
            $result = winget install --id $runtime.ID --silent --accept-package-agreements --accept-source-agreements 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host " Done" -ForegroundColor Green
                $succeeded += $runtime.Name
            } else {
                Write-Host " Failed" -ForegroundColor Red
                $failed += $runtime.Name
            }
        }
    }

    # --- End screen ---
    Clear-Host
    Write-Host "=== Update Drivers Complete ===" -ForegroundColor Cyan
    Write-Host ""

    if ($succeeded.Count -gt 0) {
        Write-Host "✓ Installed ($($succeeded.Count)): $($succeeded -join ', ')" -ForegroundColor Green
    }
    if ($failed.Count -gt 0) {
        Write-Host "✗ Failed ($($failed.Count)): $($failed -join ', ')" -ForegroundColor Red
    }
    if ($succeeded.Count -eq 0 -and $failed.Count -eq 0) {
        Write-Host "No runtimes were processed." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "[R] Return to menu   [0] Exit" -ForegroundColor DarkGray
    Write-Host ""

    do {
        $key = [Console]::ReadKey($true).Key
        if ($key -eq "R" -or $key -eq "Escape") { return }
        if ($key -eq "D0" -or $key -eq "NumPad0") {
            Clear-Host
            Write-Host "Exiting Windows Optimizer. Goodbye!" -ForegroundColor Green
            exit
        }
    } while ($true)
}

function Invoke-OptimizeSystem {
    Clear-Host
    Write-Host "=== Optimize System ===" -ForegroundColor Cyan
    Write-Host ""

    $changes = @(
        "Delivery Optimization — Disable P2P upload"
        "Refresh Rate — Set to maximum"
        "Mouse Acceleration — Disable"
        "Power Plan — Set to High Performance"
        "Xbox Game Bar — Disable"
        "Startup Delay — Disable"
        "Hibernation — Disable"
        "Sticky Keys — Disable"
        "Activity History — Disable"
        "Location Tracking — Disable"
        "Widgets — Remove"
        "Windows AI Features — Disable"
        "Classic Context Menu — Enable"
        "Bing Search — Disable in Start Menu"
        "Ultimate Performance — Enable"
        "Windows Sandbox — Enable"
    )

    Write-Host "The following changes will be applied:" -ForegroundColor DarkGray
    Write-Host ""
    for ($i = 0; $i -lt $changes.Count; $i++) {
        Write-Host "  $($i + 1). $($changes[$i])"
    }
    Write-Host ""
    Write-Host "[Y] Apply all  [N] Cancel" -ForegroundColor DarkGray
    Write-Host ""

    do {
        $key = [Console]::ReadKey($true).Key
        if ($key -eq "N") { return }
    } while ($key -ne "Y")

    $succeeded = 0
    $failed = 0

    # --- Create restore point ---
    try {
        Checkpoint-Computer -Description "Windows Optimizer - Before optimization" -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
        Write-Host "  ✓ System restore point created" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ! System restore point creation failed (service may be disabled): $_" -ForegroundColor Yellow
    }

    Clear-Host
    Write-Host "=== Optimize System ===" -ForegroundColor Cyan
    Write-Host ""

    # 1. Delivery Optimization — Disable P2P upload
    try {
        $null = New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Value 0 -Type DWord -ErrorAction Stop
        Write-Host "  ✓ $($changes[0])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[0])" -ForegroundColor Red
        $failed++
    }

    # 2. Refresh Rate — Set to maximum
    try {
        if (-not ([System.Management.Automation.PSTypeName]'DisplayChanger').Type) {
            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class DisplayChanger {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int EnumDisplaySettings(string lpszDeviceName, int iModeNum, ref DEVMODE lpDevMode);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int ChangeDisplaySettings(ref DEVMODE lpDevMode, int dwFlags);

    public const int ENUM_CURRENT_SETTINGS = -1;
    public const int CDS_UPDATEREGISTRY = 0x01;
    public const int DISP_CHANGE_SUCCESSFUL = 0;

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmDeviceName;
        public short dmSpecVersion;
        public short dmDriverVersion;
        public short dmSize;
        public short dmDriverExtra;
        public int dmFields;
        public short dmOrientation;
        public short dmPaperSize;
        public short dmPaperLength;
        public short dmPaperWidth;
        public short dmScale;
        public short dmCopies;
        public short dmDefaultSource;
        public short dmPrintQuality;
        public short dmColor;
        public short dmDuplex;
        public short dmYResolution;
        public short dmTTOption;
        public short dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmFormName;
        public short dmLogPixels;
        public int dmBitsPerPel;
        public int dmPelsWidth;
        public int dmPelsHeight;
        public int dmDisplayFlags;
        public int dmDisplayFrequency;
        public int dmICMMethod;
        public int dmICMIntent;
        public int dmMediaType;
        public int dmDitherType;
        public int dmReserved1;
        public int dmReserved2;
        public int dmPanningWidth;
        public int dmPanningHeight;
    }

    public static DEVMODE GetCurrentSettings() {
        DEVMODE dm = new DEVMODE();
        dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
        EnumDisplaySettings(null, ENUM_CURRENT_SETTINGS, ref dm);
        return dm;
    }

    public static int FindMaxRefresh(int w, int h) {
        DEVMODE dm = new DEVMODE();
        dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
        int max = 0;
        int n = 0;
        while (EnumDisplaySettings(null, n, ref dm) != 0) {
            if (dm.dmPelsWidth == w && dm.dmPelsHeight == h && dm.dmDisplayFrequency > max)
                max = dm.dmDisplayFrequency;
            n++;
        }
        return max;
    }

    public static int Apply(int w, int h, int freq) {
        DEVMODE dm = new DEVMODE();
        dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
        int n = 0;
        while (EnumDisplaySettings(null, n, ref dm) != 0) {
            if (dm.dmPelsWidth == w && dm.dmPelsHeight == h && dm.dmDisplayFrequency == freq)
                return ChangeDisplaySettings(ref dm, CDS_UPDATEREGISTRY);
            n++;
        }
        return -1;
    }
}
'@ -ErrorAction Stop
        }

        $current = [DisplayChanger]::GetCurrentSettings()
        $w = $current.dmPelsWidth
        $h = $current.dmPelsHeight
        $currentFreq = $current.dmDisplayFrequency
        $maxFreq = [DisplayChanger]::FindMaxRefresh($w, $h)

        if ($maxFreq -gt 0 -and $maxFreq -gt $currentFreq) {
            $result = [DisplayChanger]::Apply($w, $h, $maxFreq)
            if ($result -eq 0) {
                Write-Host "  ✓ $($changes[1]) ($maxFreq Hz)" -ForegroundColor Green
                $succeeded++
            } else {
                Write-Host "  ! $($changes[1]) — Failed to apply ($maxFreq Hz)" -ForegroundColor Yellow
            }
        } elseif ($maxFreq -le 0) {
            Write-Host "  ! $($changes[1]) — No available modes found" -ForegroundColor Yellow
        } else {
            Write-Host "  ! $($changes[1]) — Already at maximum ($currentFreq Hz)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ! $($changes[1])" -ForegroundColor Yellow
    }

    # 3. Mouse Acceleration — Disable
    try {
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0 -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0 -ErrorAction Stop

        if (-not ([System.Management.Automation.PSTypeName]'MouseHelper').Type) {
            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class MouseHelper {
    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);

    public const uint SPI_SETMOUSE = 0x0004;
    public const uint SPIF_UPDATEINIFILE = 0x01;
    public const uint SPIF_SENDCHANGE = 0x02;

    public static void DisableAccel() {
        int[] values = new int[] { 0, 0, 0 };
        IntPtr ptr = Marshal.AllocHGlobal(12);
        try {
            Marshal.Copy(values, 0, ptr, 3);
            SystemParametersInfo(SPI_SETMOUSE, 0, ptr, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        } finally {
            Marshal.FreeHGlobal(ptr);
        }
    }
}
'@ -ErrorAction Stop
        }

        [MouseHelper]::DisableAccel()

        Write-Host "  ✓ $($changes[2])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[2])" -ForegroundColor Red
        $failed++
    }

    # 4. Power Plan — Set to High Performance
    try {
        $null = powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1
        if ($LASTEXITCODE -ne 0) { throw "powercfg failed" }
        Write-Host "  ✓ $($changes[3])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[3])" -ForegroundColor Red
        $failed++
    }

    # 5. Xbox Game Bar — Disable
    $gameBarOk = $true
    try {
        $null = New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -ErrorAction Stop
    } catch {
        $gameBarOk = $false
    }
    try {
        $null = New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord -ErrorAction Stop
    } catch {
        $gameBarOk = $false
    }
    if ($gameBarOk) {
        Write-Host "  ✓ $($changes[4])" -ForegroundColor Green
        $succeeded++
    } else {
        Write-Host "  ✗ $($changes[4])" -ForegroundColor Red
        $failed++
    }

    # 6. Startup Delay — Disable
    try {
        $null = New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0 -Type DWord -ErrorAction Stop
        Write-Host "  ✓ $($changes[5])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[5])" -ForegroundColor Red
        $failed++
    }

    # 7. Hibernation — Disable
    try {
        $null = powercfg /hibernate off 2>&1
        if ($LASTEXITCODE -ne 0) { throw "powercfg failed" }
        Write-Host "  ✓ $($changes[6])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[6])" -ForegroundColor Red
        $failed++
    }

    # Disable Sticky Keys
    try {
        $null = New-Item -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506" -ErrorAction Stop
        Write-Host "  ✓ $($changes[7])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[7])" -ForegroundColor Red
        $failed++
    }

    # Disable Activity History
    try {
        $null = New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord -ErrorAction Stop
        Write-Host "  ✓ $($changes[8])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[8])" -ForegroundColor Red
        $failed++
    }

    # Disable Location Tracking
    try {
        $null = New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -ErrorAction Stop
        Write-Host "  ✓ $($changes[9])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[9])" -ForegroundColor Red
        $failed++
    }

    # Remove Widgets
    try {
        # Hide widgets from taskbar
        $null = New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -ErrorAction Stop
        # Unregister Widgets package
        $widgetPkg = Get-AppxPackage -Name "*WebExperience*" -ErrorAction SilentlyContinue
        if ($widgetPkg) {
            Remove-AppxPackage -Package $widgetPkg -ErrorAction SilentlyContinue
        }
        Write-Host "  ✓ $($changes[10])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[10])" -ForegroundColor Red
        $failed++
    }

    # Disable Windows AI Features
    try {
        # Disable Copilot
        $null = New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0 -Type DWord -ErrorAction Stop
        # Disable Copilot via policy
        $null = New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -ErrorAction Stop
        Write-Host "  ✓ $($changes[11])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[11])" -ForegroundColor Red
        $failed++
    }

    # Enable Classic Context Menu
    try {
        $null = New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)" -Value "" -ErrorAction Stop
        Write-Host "  ✓ $($changes[12])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[12])" -ForegroundColor Red
        $failed++
    }

    # Disable Bing Search in Start Menu
    try {
        $null = New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord -ErrorAction Stop
        Write-Host "  ✓ $($changes[13])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[13])" -ForegroundColor Red
        $failed++
    }

    # Enable Ultimate Performance Power Plan
    try {
        $null = powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
        $null = powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
        Write-Host "  ✓ $($changes[14])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[14])" -ForegroundColor Red
        $failed++
    }

    # Enable Windows Sandbox
    try {
        $null = Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online -All -NoRestart -ErrorAction Stop
        Write-Host "  ✓ $($changes[15])" -ForegroundColor Green
        $succeeded++
    } catch {
        Write-Host "  ✗ $($changes[15])" -ForegroundColor Red
        $failed++
    }

    Write-Host ""
    if ($failed -eq 0) {
        Write-Host "Summary: $succeeded applied, all successful!" -ForegroundColor Green
    } else {
        Write-Host "Summary: $succeeded applied, $failed failed" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "[R] Return to menu   [0] Exit" -ForegroundColor DarkGray
    Write-Host ""

    do {
        $key = [Console]::ReadKey($true).Key
        if ($key -eq "R" -or $key -eq "Escape") { return }
        if ($key -eq "D0" -or $key -eq "NumPad0") {
            Clear-Host
            Write-Host "Exiting Windows Optimizer. Goodbye!" -ForegroundColor Green
            exit
        }
    } while ($true)
}

function Show-Menu {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "║" -ForegroundColor DarkGray -NoNewline
    Write-Host "        Windows Optimizer — Gaming PC     " -ForegroundColor Cyan -NoNewline
    Write-Host "║" -ForegroundColor DarkGray
    Write-Host "╠══════════════════════════════════════════╣" -ForegroundColor DarkGray
    Write-Host "║  [1]  Privacy & Telemetry               ║" -ForegroundColor DarkGray
    Write-Host "║  [2]  Debloat Windows                   ║" -ForegroundColor DarkGray
    Write-Host "║  [3]  Install Apps                      ║" -ForegroundColor DarkGray
    Write-Host "║  [4]  Update Drivers                    ║" -ForegroundColor DarkGray
    Write-Host "║  [5]  Optimize System                   ║" -ForegroundColor DarkGray
    Write-Host "║                                          ║" -ForegroundColor DarkGray
    Write-Host "║  [0]  Exit                              ║" -ForegroundColor DarkGray
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host "`nSelect an option: " -NoNewline

    $key = [Console]::ReadKey($true).KeyChar
    return [int]$key - [int][char]'0'
}

try {
    do {
        $choice = Show-Menu
        switch ($choice) {
            1 { Invoke-PrivacyTelemetry }
            2 { Invoke-DebloatWindows }
            3 { Invoke-AppInstaller }
            4 { Invoke-UpdateDrivers }
            5 { Invoke-OptimizeSystem }
            0 {
                Clear-Host
                Write-Host "Exiting Windows Optimizer. Goodbye!" -ForegroundColor Green
                return
            }
            default {
                Write-Host "Invalid option" -ForegroundColor Red
                Start-Sleep -Milliseconds 600
            }
        }
    } while ($choice -ne 0)
}
finally {
    Write-Host "Cleanup complete." -ForegroundColor DarkGray
}
