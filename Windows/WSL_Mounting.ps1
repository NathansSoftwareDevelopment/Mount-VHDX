# Run as admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}   

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