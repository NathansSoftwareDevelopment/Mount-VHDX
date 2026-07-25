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
$LogFilePath = "$PSScriptRoot\..\Logs\$LogFileName"
$LogFile = [System.IO.StreamWriter]::new(<# Path #> "$LogFilePath", <# Append Mode #> $true ) # Also creates file if does not exist
$LogFile.AutoFlush = $true

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
    $LogFile.Write($Lines)
}

$HumanOriginalStartTime = FormatUnixToHumanReadable $OriginalStartTime
$OriginalStartTimeText = "$PSCommandPath Began at $OriginalStartTime ($HumanOriginalStartTime)"
$LogFile.WriteLine($OriginalStartTimeText)

$HumanStartTime = FormatUnixToHumanReadable $StartTime
$StartTimeText = "$PSCommandPath Began with Administrator Privileges at $StartTime ($HumanStartTime)"
$LogFile.WriteLine($StartTimeText)
NewLine

function LogExit {
    return "Exit Code: $LASTEXITCODE"
}

# Make WSL treat data.vhdx as BTRFS
$VHDXPath = "D:\data.vhdx"
$VHDXExistence = if (Test-Path -Path $VHDXPath) {"does exist"} else {"does not exist"}
$LogFile.WriteLine("VHDX Path ($VHDXPath) $VHDXExistence")
$env:WSL_UTF8 = 1
$VHDXMountingMessage = wsl --mount --vhd --bare --name btrfsdata "$VHDXPath" 2>&1
$LogFile.WriteLine("$VHDXMountingMessage")
$LogFile.WriteLine("$(LogExit)")
NewLine

# Create directory inwhich to mount BTRFS partition
$MountName = "data"
$MountPoint = "/mnt/$MountName"
$LogFile.WriteLine("Mount Point is $MountPoint")
wsl -d Ubuntu -u root mkdir -p "$MountPoint"
$Mounts = wsl -d Ubuntu ls /mnt/ 2>$1
$MountPointExistence = if ($Mounts.Contains($MountName)) {"does exist"} else {"does not exist"}
$LogFile.WriteLine("Mount Point $MountPointExistence in /mnt/")
$LogFile.WriteLine("ls /mnt/ shows:`r`n    " + [regex]::Replace($Mounts, '\s+', "`r`n    ") + "`r`n    $(LogExit)")
NewLine

# Actually mount BTRFS partition (using UUID because /dev/sdX is volatile)
$DriveUUID = "4c7599f8-27c8-4dbd-b54d-8ae41ea7dd67"
$LogFile.WriteLine("Drive UUID is $DriveUUID")
$DriveMountingMessage = wsl -d Ubuntu -u root mount UUID="$DriveUUID" "$MountPoint" 2>&1
$LogFile.WriteLine("$DriveMountingMessage")
$LogFile.WriteLine("$(LogExit)")
$FindMount = (wsl findmnt UUID=$DriveUUID) -join "`r`n    " 2>&1
$LogFile.WriteLine("findmnt shows:`r`n    $FindMount`r`n    $(LogExit)")

$LogFile.Close()
wsl -d Ubuntu -u root sleep infinity