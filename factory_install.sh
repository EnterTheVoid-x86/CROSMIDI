#!/bin/bash

clear

releaseBuild=0
				   # the text below this is false
if [[ $releaseBuild -eq 1 ]]; then # i am stupid and incompitent :3 
	trap '' INT
fi

funText() {
	splashText=("Now in active development... again!" "Fun fact: I have no idea what the fuck I'm doing - Archimax" "Did you know that originally this whole script was skidded? It still is!" "I eated CROSMIDI" "Nom nom tasty shims" "How the fuck is this working? No clue!" "Shimmy shimmy yay shimmy yay shimmy yah" "I hate arm boards I hate arm boards I hate arm boards" "someone get writable to deliver his expertiese in this situation" "whelement unenrollment eta 1-920,613,220 years")
 	# will add more text later
  	selectedSplashText=${splashText[$RANDOM % ${#splashText[@]}]} # def didn't get this from chatgpt
   	echo "                                                                      $selectedSplashText"
}

# thx to stella and boeing for cool splash text and removing r58's code (force push did a little removing commit history lol)

splash() {
	# why did i put the logo all in one line?
	echo -e " e88~-_  888~-_     ,88~-_   ,d88~~\      e    e      888 888~-_   888\nd888   \ 888   \   d888   \  8888        d8b  d8b     888 888   \  888\n8888     888    | 88888    | \`Y88b      d888bdY88b    888 888    | 888\n8888     888   /  88888    |  \`Y88b,   / Y88Y Y888b   888 888    | 888\nY888   / 888_-~    Y888   /     8888  /   YY   Y888b  888 888   /  888\n \"88_-~  888 ~-_    \`88_-~   \__88P' /          Y888b 888 888_-~   888\n"
	echo "                                                                    or"
	echo "                             ChromeOS Multi-Image Deployment Interface"
	echo "                                                                 v0.8a"
 	funText
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
		
		if [[ ! -f /mnt/crosmidi/shims/$shimtoboot ]]
		then
			echo "File not found! Try again."
		else
			echo "I'll figure this shit out later lmao."
		fi
	done
	read -p "Press any key to continue"
	losetup -D
	splash
}

installcros() {
	echo "intcros"
	usbdev="$(cgpt find -l SH1MMER | head -n 1 | grep --color=never /dev/)"
	findinternal
	while true; do
 		echo "NOT IMPLEMENTED, images will not flash, type 'exit' to return to the crosmidi menu."
		read -p "Please choose an image to recover with: " reco
		
		if [[ $reco == "exit" ]]
		then
			break
		fi
  
  		if [[ ! -f /mnt/crosmidi/recovery/$reco ]]; then
			echo "File not found! Try again."
		else
  			echo "I said type exit..."
     			break
		fi
	done
}

findinternal() {
	# assumes the user doesnt have a cros reco image pluged into device (that isnt on the shim) or this will prob break lol
	# you also cant have a device with the letter p in it (like /dev/sdp (mmcblk0p1 is fine bc the p is part of the partiton shit)) or it will break :3
	# totally wasnt getting impatient with chat gpt and just decided to remove any and all p's
	echo "findint"
	devs=$(lsblk -dn -o NAME | grep -E 'sd|nvme|mmcblk')
	crosfound=0
	crmidifound=0

	for dev in $devs; do
    	prt=$(blkid | grep "ROOT-A" | awk -F ':' '{print $1}' | sed 's/[0-9]*$//' | sed 's/p//g')
    	crosmidi_prt=$(blkid | grep "SH1MMER" | awk -F ':' '{print $1}' | sed 's/[0-9]*$//' | sed 's/p//g')
		# SH1MMER as placeholder bc that's how im testing the script

		if [[ -n "$crosmidi_prt" && "$crosmidi_prt" == "/dev/$dev" && "$crmidifound" -eq 1 ]]; then 
			echo "CROSMIDI found twice... what????"
		fi

		if [[ -n "$crosmidi_prt" && "$crosmidi_prt" == "/dev/$dev" ]]; then
			echo "USB found $dev $crosmidi_prt"
			crmidifound=1
			continue
		fi
		
		if [[ -n "$prt" && "$prt" =~ "/dev/$dev" &&  "$crosfound" -eq 1 ]]; then 
			echo "cros found twice. do you have a recovery image plugged in other than the one(s) on this usb? it should be fine if not"
		fi

    	if [[ -n "$prt" && "$prt" =~ "/dev/$dev" ]]; then
			echo "CROS found"
			echo "$dev $prt"
			crosfound=1
			internalstorage="/dev/$dev"
    	fi
	done
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

