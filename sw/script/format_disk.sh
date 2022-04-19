#!/bin/bash

BOOTLOADER=bootloader/bootloader.bin
DEVICE=/dev/mmcblk0
TMPBOOTSECT=/tmp/bootsect
TMPMOUNT=/tmp/sd

V=
STATUS="status=none"

echo "$(tput bold setaf 11)Creating Filesystem$(tput sgr 0)"
sudo mkfs.vfat -F32 $DEVICE -n SUPER6502 $V
echo

echo "$(tput bold setaf 11)Modifying Boot Sector$(tput sgr 0)"
sudo dd if=$DEVICE of=$TMPBOOTSECT bs=512 count=1 $STATUS
sudo dd conv=notrunc if=$BOOTLOADER of=$DEVICE bs=512 skip=0 count=1 $STATUS
sudo dd conv=notrunc if=$TMPBOOTSECT of=$DEVICE bs=1 skip=0 count=90 iflag=skip_bytes,count_bytes $STATUS
sudo dd conv=notrunc if=$BOOTLOADER of=$DEVICE bs=1 skip=0 count=3 iflag=skip_bytes,count_bytes $STATUS
echo

echo "$(tput bold setaf 10)Done!$(tput sgr 0)"

