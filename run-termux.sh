#!/bin/bash

mkdir iso/
rm iso/os.bin

echo
echo
fasm-wrapper.sh bootloader.asm iso/os.bin
echo
fasm-wrapper.sh programs/calculator.asm iso/calc.bin
echo
# fasm-wrapper.sh programs/notepad.asm iso/notepad.bin
# echo
fasm-wrapper.sh programs/viewer.asm iso/viewer.bin
echo
echo

cd iso

rm boot.img
dd if=/dev/zero of=boot.img bs=1024 count=1440
dd if=os.bin of=boot.img conv=notrunc
dd if=calc.bin of=boot.img conv=notrunc bs=512 seek=16
# dd if=notepad.bin of=boot.img conv=notrunc bs=512 seek=17
dd if=viewer.bin of=boot.img conv=notrunc bs=512 seek=17
dd if=calc.bin of=boot.img bs=512 seek=19 conv=notrunc
# dd if=just_text.t of=boot.img conv=notrunc bs=512 seek=23


cd ..

# qemu-system-i386 iso/os.bin
qemu-system-i386 -fda iso/boot.img
