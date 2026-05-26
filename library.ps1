<#
.SYNOPSIS
    App registry / stub library for Windows Optimizer.

.DESCRIPTION
    This file is the single source of truth for all installable apps in the
    Windows Optimizer tool. It is dot-sourced by optimize.ps1 (Feature 3,
    Milestone 5) so that $AppLibrary is available in the caller's scope.

    STRUCTURE
    $AppLibrary is a hashtable whose keys are category names (strings) and
    whose values are arrays of app-object hashtables.

    APP-OBJECT SCHEMA
    @{
        Name = "Display Name"       # Human-readable name shown in the UI
        ID   = "Publisher.PackageId"  # winget package identifier
    }

    HOW TO ADD A NEW APP
    Add one line to the correct category array below.  No other file needs
    to change — the app will automatically appear in the installer menu.
#>

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
}
