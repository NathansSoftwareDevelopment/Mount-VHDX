$StartTime = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()

# Run as admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}   

# Create log file
$FileExplorerTime = [DateTimeOffset]::FromUnixTimeMilliseconds($StartTime).LocalDateTime.ToString("yyyy-MM-dd_HH-mm-ss")
$LogFileName = "${FileExplorerTime}_Windows.log"
$LogFile = "$PSScriptRoot\..\Logs\$LogFileName"
New-Item -Path $LogFile -ItemType File

function FormatUnixToHumanReadable {
    param(
        [long]$UnixTime
    )

    return [DateTimeOffset]::FromUnixTimeMilliseconds($UnixTime).ToLocalTime().ToString("yyyy-MM-dd, HH-mm-ss tt, UTCz")
}

$HumanTime = FormatUnixToHumanReadable $StartTime
$StartTimeText = "$PSCommandPath Began at $StartTime ($HumanTime)"
Add-Content -Path $LogFile -Value $StartTimeText

# Make WSL treat data.vhdx as BTRFS
$VHDXPath = "D:\data.vhdx"
wsl --mount --vhd --bare --name btrfsdata "$VHDXPath"

# Create directory inwhich to mount BTRFS partition
$MountPoint = "/mnt/data"
wsl -d Ubuntu -u root mkdir -p "$MountPoint"

# Actually mount BTRFS partition (using UUID because /dev/sdX is volatile)
$DriveUUID = "4c7599f8-27c8-4dbd-b54d-8ae41ea7dd67"
wsl -d Ubuntu -u root mount UUID="$DriveUUID" "$MountPoint"

wsl -d Ubuntu -u root sleep infinity