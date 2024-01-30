# ChRomeOS Multi-Image Deployment Interface

## What is it?
To sum it up, it's like Ventoy for Chromebooks that have RMA Shims.

## What can it do?
Many things. Booting other modified RMA shims like TerraOS, Shimboot and SH1MMER, installing different ChromeOS recovery images without the need to reformat your USB every time, among other things.

## How does it work?
Using a modified RMA Shim, you'll be presented with a menu to choose your action. Available options are b (bash shell), r (reboot), p (poweroff), i (install a recovery image), and s (boot an RMA shim). Installing a recovery image mounts the disk image with losetup, partitions the internal storage, and flashes the partitions to the disk.

## Supported devices?
Anything with a publicly available RMA shim.
