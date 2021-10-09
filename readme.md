# Arch GSP 670 Stereo Patch
Patches the USB sound module of (Arch)-Linux to support stereo sound.

The patch-script is based on the fix of the user "Kealy" in https://bbs.archlinux.org/viewtopic.php?id=251068 and just automates the steps done there.

## Usage
### Arch-Linux
**NOTE: This script is only tested and built for Arch-Linux**

Basic usage:
```
./patch.sh
```

### Other Linux-Distros
It should work similarly under other Linux distributions. In the end you only have to patch the file sound/usb/card.c and build the sound module (or a whole kernel) from it.
