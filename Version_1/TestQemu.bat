@echo off

echo Launch Qemu

rem For Raspberry Pi Zero uncomment next line
qemu-system-arm -kernel pigfx.elf -cpu arm1176 -m 512 -M raspi0 -no-reboot -serial stdio -append ""

pause








