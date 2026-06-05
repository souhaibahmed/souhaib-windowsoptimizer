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
    "Browsers" = @(
        @{ Name = "Brave";          ID = "Brave.Brave" },
        @{ Name = "Google Chrome";  ID = "Google.Chrome" },
        @{ Name = "Chromium";       ID = "Hibbiki.Chromium" },
        @{ Name = "Firefox";        ID = "Mozilla.Firefox" },
        @{ Name = "Waterfox";       ID = "Waterfox.Waterfox" },
        @{ Name = "Opera";          ID = "Opera.Opera" },
        @{ Name = "Opera GX";       ID = "Opera.OperaGX" },
        @{ Name = "Tor Browser";    ID = "TorProject.TorBrowser" },
        @{ Name = "LibreWolf";      ID = "LibreWolf.LibreWolf" },
        @{ Name = "Zen Browser";    ID = "Zen-Team.Zen-Browser" }
    )
    "Communication" = @(
        @{ Name = "Discord";           ID = "Discord.Discord" },
        @{ Name = "Vencord";           ID = "Vendicated.Vencord" },
        @{ Name = "Microsoft Teams";   ID = "Microsoft.Teams" },
        @{ Name = "Zoom";              ID = "Zoom.Zoom" },
        @{ Name = "Telegram";          ID = "Telegram.TelegramDesktop" },
        @{ Name = "WhatsApp";          ID = "WhatsApp.WhatsApp" }
    )
    "Media & Documents" = @(
        @{ Name = "VLC";                    ID = "VideoLAN.VLC" },
        @{ Name = "K-Lite Codec Pack Full"; ID = "CodecGuide.K-LiteCodecPack.Full" },
        @{ Name = "Audacity";               ID = "Audacity.Audacity" },
        @{ Name = "Spotify";                ID = "Spotify.Spotify" },
        @{ Name = "OBS Studio";             ID = "OBSProject.OBSStudio" },
        @{ Name = "Adobe Acrobat Reader";   ID = "Adobe.Acrobat.Reader.64-bit" }
    )
    "Gaming" = @(
        @{ Name = "Steam";                  ID = "Valve.Steam" },
        @{ Name = "Epic Games";             ID = "EpicGames.EpicGamesLauncher" },
        @{ Name = "GOG Galaxy";             ID = "GOG.Galaxy" },
        @{ Name = "EA App";                 ID = "ElectronicArts.EADesktop" },
        @{ Name = "Ubisoft Connect";        ID = "Ubisoft.Connect" },
        @{ Name = "Minecraft Launcher";     ID = "Mojang.MinecraftLauncher" },
        @{ Name = "Playnite";               ID = "Playnite.Playnite" },
        @{ Name = "PPSSPP";                 ID = "PPSSPPTeam.PPSSPP" }
    )
    "System Monitoring" = @(
        @{ Name = "MSI Afterburner";    ID = "Guru3D.Afterburner" },
        @{ Name = "HWiNFO";             ID = "REALiX.HWiNFO" },
        @{ Name = "CPU-Z";              ID = "CPUID.CPU-Z" },
        @{ Name = "GPU-Z";              ID = "TechPowerUp.GPU-Z" },
        @{ Name = "CrystalDiskInfo";    ID = "CrystalDewWorld.CrystalDiskInfo" }
    )
    "Utilities" = @(
        @{ Name = "AnyDesk";                    ID = "AnyDesk.AnyDesk" },
        @{ Name = "TeamViewer";                 ID = "TeamViewer.TeamViewer" },
        @{ Name = "Revo Uninstaller";           ID = "RevoUninstaller.RevoUninstaller" },
        @{ Name = "Everything";                 ID = "voidtools.Everything" },
        @{ Name = "WinRAR";                     ID = "RARLab.WinRAR" },
        @{ Name = "7-Zip";                      ID = "7zip.7zip" },
        @{ Name = "PeaZip";                     ID = "PeaZip.PeaZip" },
        @{ Name = "PowerToys";                  ID = "Microsoft.PowerToys" },
        @{ Name = "ShareX";                     ID = "ShareX.ShareX" },
        @{ Name = "LocalSend";                  ID = "LocalSend.LocalSend" },
        @{ Name = "Internet Download Manager";  ID = "Tonec.InternetDownloadManager" },
        @{ Name = "Neat Download Manager";      ID = "JavadMotallebi.NeatDownloadManager" },
        @{ Name = "Free Download Manager";      ID = "SoftDeluxe.FreeDownloadManager" }
    )
    "Developer Tools" = @(
        @{ Name = "Python 3";           ID = "Python.Python.3" },
        @{ Name = "Git";                ID = "Git.Git" },
        @{ Name = "Notepad++";          ID = "Notepad++.Notepad++" },
        @{ Name = "Visual Studio Code"; ID = "Microsoft.VisualStudioCode" }
    )
}
