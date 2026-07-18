# Run as admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}   

# Make WSL treat data.vhdx as BTRFS
wsl --mount --vhd --bare --name btrfsdata "D:\data.vhdx"
# Create directory inwhich to mount BTRFS partition
wsl -d Ubuntu sudo mkdir -p /mnt/data
# Actually mount BTRFS partition (using UUID because /dev/sdX is volatile)
wsl -d Ubuntu sudo mount UUID="4c7599f8-27c8-4dbd-b54d-8ae41ea7dd67" /mnt/data
