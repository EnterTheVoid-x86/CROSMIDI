```
 e88~-_  888~-_     ,88~-_   ,d88~~\      e    e      888 888~-_   888
d888   \ 888   \   d888   \  8888        d8b  d8b     888 888   \  888
8888     888    | 88888    | `Y88b      d888bdY88b    888 888    | 888
8888     888   /  88888    |  `Y88b,   / Y88Y Y888b   888 888    | 888
Y888   / 888_-~    Y888   /     8888  /   YY   Y888b  888 888   /  888
 "88_-~  888 ~-_    `88_-~   \__88P' /          Y888b 888 888_-~   888
```

# ChromeOS Multi-Image Deployment Interface

## What is it?
~~Incredibly skidded.~~\
ChromeOS Multi-Image Deployment Interface is a Ventoy-type program that allows you to boot multiple RMA shims with only one USB. 

## What can it do?
~~recovery!~~\
Many things. Booting other modified RMA shims like TerraOS and SH1MMER (or stock shims), installing different ChromeOS recovery images without the need to reformat your USB every time, among other things.

## How does it work?
~~It does :3.~~\
Using a modified RMA Shim, you'll be presented with a menu to choose your action. Available options are `b` (bash shell), `r` (reboot), `p` (poweroff), `i` (install a recovery image), and `s` (boot an RMA shim). Installing a recovery image mounts the disk image with losetup, partitions the internal storage, and flashes the partitions to the disk.

## Supported devices?
Anything with a publicly available RMA shim.

## Building 
Linux (wsl might work but no promises): clone this repo and cd into it, copy your sh1mmer legacy image into the folder, then run `crosmidi_builder.sh [image.bin]`. 
Flash the image to a usb with DD or whatever you want, unmount partiiton 5 if it mounted, then run (please someone find a better way to do this, this is just simple so im using it for now) 
`sudo growpart /dev/[device] 5
sudo e2fsck -f /dev/[device]5
sudo resize2fs /dev/[device]5`
(yes there's supposed to be a space between the device and 5 on the first command.)
mount the 5th partition and put your shims and recovery images in the respective folders, then boot the usb like you would sh1mmer.

## Credits
Archimax/EnterTheVoid-x86: Pioneering the creation of this tool (programming, naming, etc)  
Zeglol1234: Helping with stuff related to switch_root  
r58playz' TerraOS: Helped me figure out some stuff with running a bash script as PID 1  
TheTechFrog: Coming up with the idea, programming recovery and the builder (kinda olyb did most of it already lol), mental support\
OlyB: making wax and doing all the hard work for the builder for us
