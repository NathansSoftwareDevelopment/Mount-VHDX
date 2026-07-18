# Create symlink to the BTRFS partition
New-Item -ItemType SymbolicLink -Path "$PSScriptRoot\WSLMountSymlink" -Target "\\wsl$\Ubuntu\mnt\data"
# Mount symlink as a Windows Drive
subst E: "$PSScriptRoot\WSLMountSymlink"