DEVICE=/dev/mmcblk0
TMPMOUNT=/tmp/sd
FSDIR=fsdir

V=

echo "$(tput bold setaf 11)Mounting Device$(tput sgr 0)"
mkdir $V -p $TMPMOUNT
sudo mount $V $DEVICE $TMPMOUNT
echo

echo "$(tput bold setaf 11)Copying Files$(tput sgr 0)"
sudo cp $V -r $FSDIR/* $TMPMOUNT
echo

echo "$(tput bold setaf 11)Unmounting Device$(tput sgr 0)"
sudo umount $V $DEVICE
rmdir $V $TMPMOUNT
echo