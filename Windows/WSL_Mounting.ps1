param(
    [long]$OriginalStartTime
)
$StartTime = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()

# Run as admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -OriginalStartTime $StartTime" -Verb RunAs -WindowStyle Hidden
    exit
}
elseif (!$OriginalStartTime) {
    $OriginalStartTime = $StartTime
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

    return [DateTimeOffset]::FromUnixTimeMilliseconds($UnixTime).ToLocalTime().ToString("yyyy-MM-dd, hh:mm:ss tt, UTCz")
}

function NewLine {
    param(
        [int]$Rows = 1
    )

    $Lines = "`n" * $Rows
    Add-Content -Path $LogFile -Value $Lines -NoNewLine
}

$HumanOriginalStartTime = FormatUnixToHumanReadable $OriginalStartTime
$OriginalStartTimeText = "$PSCommandPath Began at $OriginalStartTime ($HumanOriginalStartTime)"
Add-Content -Path $LogFile -Value $OriginalStartTimeText

$HumanStartTime = FormatUnixToHumanReadable $StartTime
$StartTimeText = "$PSCommandPath Began with Administrator Privileges at $StartTime ($HumanStartTime)"
Add-Content -Path $LogFile -Value $StartTimeText
NewLine

# Make WSL treat data.vhdx as BTRFS
$VHDXPath = "D:\data.vhdx"
$VHDXExistence = if (Test-Path -PAth $VHDXPath) {"does exist"} else {"does not exist"}
Add-Content -Path $LogFile -Value "VHDX Path ($VHDXPath) $VHDXExistence"
NewLine
$env:WSL_UTF8 = 1
$VHDXMountingMessage = wsl --mount --vhd --bare --name btrfsdata "$VHDXPath" 2>&1
Add-Content -Path $LogFile $VHDXMountingMessage
Add-Content -Path $LogFile "Exit Code: $LASTEXITCODE"
NewLine 2

# Create directory inwhich to mount BTRFS partition
$MountPoint = "/mnt/data"
wsl -d Ubuntu -u root mkdir -p "$MountPoint"

# Actually mount BTRFS partition (using UUID because /dev/sdX is volatile)
$DriveUUID = "4c7599f8-27c8-4dbd-b54d-8ae41ea7dd67"
wsl -d Ubuntu -u root mount UUID="$DriveUUID" "$MountPoint"

wsl -d Ubuntu -u root sleep infinity