#!/bin/bash

BOOTLOADER=$REPO_TOP/sw/bios/bootloader.bin
FILE=fs.fat

TMPMOUNT=/tmp/lo
FSDIR=$REPO_TOP/sw/fsdir

MNT=/run/media/$USER/SUPER6502

V=-v

# Smallest number of blocks where mkfs doesn't complain
BLOCKS=33296

rm $FILE

echo "$(tput bold setaf 11)Creating Filesystem$(tput sgr 0)"
mkfs.vfat $V -I -F32 -C $FILE -n SUPER6502 $BLOCKS
echo

echo "$(tput bold setaf 11)Modifying Boot Sector$(tput sgr 0)"
dd if=$BOOTLOADER of=$FILE bs=1 conv=notrunc count=11 $STATUS
dd if=$BOOTLOADER of=$FILE bs=1 conv=notrunc count=380 seek=71 skip=71 $STATUS


LOOP=$(udisksctl loop-setup -f $FILE | grep -o "/dev/loop\([0-9]\)\+")
MNT=$(udisksctl mount -b $LOOP $TMPMOUNT | grep -o "\([A-Za-z/-]*/\)SUPER6502")

echo "$(tput bold setaf 11)Copying Files$(tput sgr 0)"
cp $V -r $FSDIR/* $MNT
echo

udisksctl unmount -b $LOOP

udisksctl loop-delete -b $LOOP

echo "$(tput bold setaf 11)Converting Image to Verilog$(tput sgr 0)"
objcopy --input-target=binary --output-target=verilog --verilog-data-width=1 $FILE $FILE.hex
echo "$(tput bold setaf 10)Done!$(tput sgr 0)"
