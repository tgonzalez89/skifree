#!/bin/sh

# This script starts the QEMU PC emulator, booting from the
# MikeOS floppy disk image

qemu-system-i386 -drive format=raw,file=disk_images/skifree.flp,index=0,if=floppy
