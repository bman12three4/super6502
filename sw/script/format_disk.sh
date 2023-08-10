#!/bin/bash

BOOTLOADER=../bios/bootloader.bin
DEVICE=/dev/mmcblk0
TMPBOOTSECT=/tmp/bootsect
TMPMOUNT=/tmp/sd

V=-v
STATUS="status=none"

echo "$(tput bold setaf 11)Creating Filesystem$(tput sgr 0)"
sudo mkfs.vfat -F32 $DEVICE -n SUPER6502 $V
echo

echo "$(tput bold setaf 11)Modifying Boot Sector$(tput sgr 0)"
sudo dd if=$BOOTLOADER of=$DEVICE bs=1 count=11 $STATUS
sudo dd if=$BOOTLOADER of=$DEVICE bs=1 count=380 seek=71 skip=71 $STATUS

echo "$(tput bold setaf 10)Done!$(tput sgr 0)"
