# Create symlink to the BTRFS partition
$SymlinkPath = "$PSScriptRoot\WSLMountSymlink"
$MountPoint = "\\wsl$\Ubuntu\mnt\data"
New-Item -ItemType SymbolicLink -Path "$SymlinkPath" -Target $MountPoint

# Mount symlink as a Windows Drive
$DriveLetter = "E"
subst "${DriveLetter}:" "$SymlinkPath"