#!/usr/bin/env bash

# i took wax, removed a bunch of stuff and changed a handful of things, thx olyb

IMAGE=$1
SCRIPT_DIR=$(dirname "$0")
SCRIPT_DIR=${SCRIPT_DIR:-"."}
. "$SCRIPT_DIR/wax_common.sh"

set -eE

[ "$EUID" -ne 0 ] && fail "Please run as root"
[ -z "$1" ] && echo "Specify a sh1mmer legacy image to modify with 'crosmidi-builder.sh image.bin'"

cleanup() {
	[ -d "$MNT_SH1MMER" ] && umount "$MNT_SH1MMER" && rmdir "$MNT_SH1MMER"
	[ -z "$LOOPDEV" ] || losetup -d "$LOOPDEV" || :	
	trap - EXIT INT
}

patch_sh1mmer() {
	log_info "Creating crosmidi images partition ($(format_bytes $SH1MMER_PART_SIZE))"
	local sector_size=$(get_sector_size "$LOOPDEV")
	cgpt_add_auto "$IMAGE" "$LOOPDEV" 5 $((SH1MMER_PART_SIZE / sector_size)) -t data -l CROSMIDI_IMAGES #this important, look at it later
	mkfs.ext4 -F -b 4096 -L CROSMIDI_IMAGES "${LOOPDEV}p5"
	
	safesync
	suppress sgdisk -e "$IMAGE" 2>&1 | sed 's/\a//g'
	safesync

	MNT_SH1MMER=$(mktemp -d)
	MNT_CROSMIDI=$(mktemp -d)
	mount "${LOOPDEV}p1" "$MNT_SH1MMER"

	log_info "Copying payload"
	cp crosmidi.sh "$MNT_SH1MMER/root/noarch/usr/sbin/sh1mmer_main.sh"
	chmod -R +x "$MNT_SH1MMER"

	umount "$MNT_SH1MMER"
	rmdir "$MNT_SH1MMER"

	mkfs.ext4 -F -b 4096 -L CROSMIDI_IMAGES "${LOOPDEV}p5"

	mount "${LOOPDEV}p5" "$MNT_CROSMIDI"

	mkdir "$MNT_CROSMIDI/shims"
	mkdir "$MNT_CROSMIDI/recovery"
	umount $MNT_CROSMIDI
	rmdir $MNT_CROSMIDI
}

trap 'echo $BASH_COMMAND failed with exit code $?. THIS IS A BUG, PLEASE REPORT!' ERR
trap 'cleanup; exit' EXIT
trap 'echo Abort.; cleanup; exit' INT
FLAGS_sh1mmer_part_size=64M
		
if [ -b "$IMAGE" ]; then
	log_info "Image is a block device, performance may suffer..."
else
	check_file_rw "$IMAGE" || fail "$IMAGE doesn't exist, isn't a file, or isn't RW"
	check_slow_fs "$IMAGE"
fi

check_gpt_image "$IMAGE" || fail "$IMAGE is not GPT, or is corrupted"

SH1MMER_PART_SIZE=$(parse_bytes "$FLAGS_sh1mmer_part_size") || fail "Could not parse size '$FLAGS_sh1mmer_part_size'"

sudo dd if=/dev/zero bs=1MiB of=$IMAGE conv=notrunc oflag=append count=100
# sane backup table
suppress sgdisk -e "$IMAGE" 2>&1 | sed 's/\a//g'

log_info "Creating loop device"
LOOPDEV=$(losetup -f)
losetup -P "$LOOPDEV" "$IMAGE"
safesync

patch_sh1mmer
safesync

losetup -d "$LOOPDEV"
safesync

suppress sgdisk -e "$IMAGE" 2>&1 | sed 's/\a//g'

log_info "Done. Have fun!"
trap - EXIT