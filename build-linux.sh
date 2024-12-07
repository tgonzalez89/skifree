#!/bin/sh

# This script assembles the SkiFree bootloader and program
# with NASM, and then creates floppy and CD images (on Linux)

# Only the root user can mount the floppy disk image as a virtual
# drive (loopback mounting), in order to copy across the files

# (If you need to blank the floppy image: 'mkdosfs disk_images/skifree.flp')


if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


echo ">>> Creating new SkiFree floppy image..."

mkdosfs -C disk_images/skifree.flp 1440 || exit


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o source/bootload/bootload.bin source/bootload/bootload.asm || exit


echo ">>> Assembling SkiFree program..."

cd source
nasm -O0 -w+orphan-labels -f bin -o skifree.bin skifree.asm || exit
cd ..


echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=source/bootload/bootload.bin of=disk_images/skifree.flp || exit


echo ">>> Copying SkiFree program..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat disk_images/skifree.flp tmp-loop && cp source/skifree.bin tmp-loop/

sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f disk_images/skifree.iso
mkisofs -quiet -V 'SKIFREE' -input-charset iso8859-1 -o disk_images/skifree.iso -b skifree.flp disk_images/ || exit

echo '>>> Done!'

