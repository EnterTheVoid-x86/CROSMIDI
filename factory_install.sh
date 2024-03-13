#!/bin/bash

# thanks to r58 for figuring out how the fuck to do this properly

clear

trap '' INT

set +x

NOSCREENS=0
MAIN_TTY="/dev/pts/0"
DEBUG_TTY="/dev/pts/1"

# sane i/o
exec >>"${MAIN_TTY}" 2>&1
exec <"${MAIN_TTY}"

# all remaining code below is 100% original

splash() {
	# why did i put the logo all in one line?
	echo -e " e88~-_  888~-_     ,88~-_   ,d88~~\      e    e      888 888~-_   888\nd888   \ 888   \   d888   \  8888        d8b  d8b     888 888   \  888\n8888     888    | 88888    | \`Y88b      d888bdY88b    888 888    | 888\n8888     888   /  88888    |  \`Y88b,   / Y88Y Y888b   888 888    | 888\nY888   / 888_-~    Y888   /     8888  /   YY   Y888b  888 888   /  888\n \"88_-~  888 ~-_    \`88_-~   \__88P' /          Y888b 888 888_-~   888\n"
	echo "                                                                    or"
	echo "                                   ChromeOS Multi-Image Deployment Hub"
	echo "                                                                 v0.8a"
	echo " "
}

splash
echo "THIS IS A PROTOTYPE BUILD, DO NOT EXPECT EVERYTHING TO WORK PROPERLY!!!"

mkdir /mnt/crosmidi
mkdir /mnt/new_root
mkdir /mnt/shimroot

shimboot() {
	crosmidi_images="$(cgpt find -l CROSMIDI_IMAGES | head -n 1 | grep --color=never /dev/)"
	mount $crosmidi_images /mnt/crosmidi
	find /mnt/crosmidi/shims -type f
	while true; do
		read -p "Please choose a shim to boot: " shimtoboot
		
		if [[ $shimtoboot == "exit" ]]
		then
			break
		fi
		
		if [ ! -f /mnt/crosmidi/shims/$shimtoboot ]
		then
			echo "File not found! Try again."
		else
			echo "Mounting shim..."
			losetup -P -f --show /mnt/crosmidi/shims/$shimtoboot
			shimroot="$(cgpt find -l ROOT-A /dev/loop0 | head -n 1 | grep --color=never /dev/)"
			shimmerroot="$(cgpt find -l SH1MMER /dev/loop0 | head -n 1 | grep --color=never /dev/)" # will only work if it's a SH1MMERED rma shim (this is so fucking stupid)
			mount $shimroot /mnt/shimroot
			echo "Copying files to tmpfs..."
			cp -r /mnt/shimroot/* /mnt/new_root
			echo "Performing additional tasks..."
			mount $shimmerroot /mnt/new_root/mnt/
			cp -r /mnt/new_root/mnt/root/* /mnt/new_root
			umount /mnt/new_root/mnt/
			mount $shimmerroot /mnt/new_root/mnt/stateful_partition
			umount $shimroot
			echo "Booting shim..."
			echo "Changing root to $shimroot. DO NOT REMOVE THE USB!!!"
			mount -t proc /proc /mnt/new_root/proc/
			mount --rbind /sys /mnt/new_root/sys/
			mount --rbind /dev /mnt/new_root/dev/
			mount --rbind /run /mnt/new_root/run/
			# echo "running switchroot in 3 seconds"
			# sleep 3
			# bash #temporary failsafe
			# exec switch_root /mnt/new_root /sbin/init - this does not work at the moment
   			chroot /mnt/new_root /usr/sbin/factory_install.sh
		fi
	done
	read -p "Press any key to continue"
	losetup -D
	splash
}

installcros() {
	crosmidi_images="$(cgpt find -l CROSMIDI_IMAGES | head -n 1 | grep --color=never /dev/)"
	mount $crosmidi_images /mnt/crosmidi
	find /mnt/crosmidi/recovery -type f
	while true; do
 		echo "NOT IMPLEMENTED, images will not flash, type 'exit' to return to the crosmidi menu."
		read -p "Please choose an image to recover with: " reco
		
		if [[ $reco == "exit" ]]
		then
			break
		fi
  
  		if [ ! -f /mnt/crosmidi/recovery/$reco ]
		then
			echo "File not found! Try again."
		else
  			echo "I said type exit..."
     			break
		fi
}

rebootdevice() {
	echo "Rebooting..."
	reboot
}

shutdowndevice() {
	echo "Shutting down..."
	shutdown -h now
}

while true; do
	echo "Select an option:"
	echo "(b) Bash shell"
	echo "(s) Boot an RMA shim"
	echo "(i) Install a ChromeOS recovery image"
	echo "(r) Reboot"
	echo "(p) Power off"
	read -p "> " choice
	case "$choice" in
	b | B) bash ;;
	r | R) rebootdevice ;;
	p | P) shutdowndevice ;;
	s | S) shimboot ;;
	i | I) installcros ;;
	*) echo "Invalid option" ;;
	esac
	echo ""
done

