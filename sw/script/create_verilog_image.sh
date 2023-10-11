
#!/bin/bash

BOOTLOADER=$REPO_TOP/sw/bios/bootloader.bin
FILE=fs.fat

TMPMOUNT=/tmp/lo
FSDIR=$REPO_TOP/sw/fsdir

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

echo "$(tput bold setaf 11)Mounting Device$(tput sgr 0)"
mkdir $V -p $TMPMOUNT
sudo mount $FILE $TMPMOUNT
echo

echo "$(tput bold setaf 11)Copying Files$(tput sgr 0)"
sudo cp $V -r $FSDIR/* $TMPMOUNT
echo

echo "$(tput bold setaf 11)Unmounting Device$(tput sgr 0)"
sudo umount $V $FILE
rmdir $V $TMPMOUNT
echo

# Really I want the data width to be 512 bytes long, not 16...
echo "$(tput bold setaf 11)Converting Image to Verilog$(tput sgr 0)"
objcopy --input-target=binary --output-target=verilog --verilog-data-width=1 $FILE $FILE.hex
echo "$(tput bold setaf 10)Done!$(tput sgr 0)"
