# Raspberry Pi Video Card
This project is based on the ["PiGFX”](https://github.com/fbergama/pigfx) repository which is an emulator for an ANSI terminal made using Raspberry Pi.

By: Lincă Marius Gheorghe.

Pitești, Argeș, Romania, Europe.

https://github.com/LincaMarius

## About the project, brief description
The goal of this project is to create a high-performance and inexpensive video card that can display a quality image with VGA and SVGA resolutions on a modern monitor.

Initially I wanted to make this project from scratch.

But I found this repository that has a concept close to my goal. The author of this project aimed at an ANSI terminal emulator. The interface with the base system is done via UART.

In order not to reinvent the wheel, I decided to start with a functional, field-tested starting point. The PiGFX project has most of the elements I was looking for.

Through this project, I want to create a video card in the form of a module that connects to the base system via a parallel interface.

## Version 1
Since the starting point of this project is “PiGFX”, the first thing to do is make sure that we can run the original files on a Raspberry Pi board.

I am using Windows 11 on my computer. So below I will describe the steps that I followed using this host operating system.

### Testing on Raspberry Pi
I followed the steps described in the original reposy:

1. I formatted an SD card using the FAT32 file system.

2. I copied to the root of the SD card the files: ```start.elf ```, ```start4.elf ``` and ```bootcode.bin ``` that are commonly [distributed with the Raspberry Pi](https://github.com/raspberrypi/firmware/tree/master/boot).

3. I copied all the files in ```Version_1/bin/*.img``` to the root of the SD card.

4. I copied the ```Version_1/bin/pigfx.txt``` file to the root of the SD card without modifying it.

5. I inserted the SD card and turned on the Raspberry Pi.

The available SD cards I use are:
- Kingston 2GB SD Card
- Hama 32 GB SD Card HC I
- Platient 64GB SD Card UHS-I

I tested PGFX on models that I have:
- Raspberry Pi Zero 2 W
- Raspberry Pi 4 Model B 8 GB

Using the Raspberry Pi Zero 2 W and the Kingston 2GB SD card without a keyboard or mouse connected, I obtained the following result:

![ Figure 1 ](/Version_1/Pictures/Figure1.jpg)

Using the Raspberry Pi 4 Model B and the Kingston 2GB SD card without a keyboard or mouse connected, I obtained the following result:

![ Figure 2 ](/Version_1/Pictures/Figure2.jpg)

The initial resolution of the displayed images is 640 x 480 @ 60 Hz.

### Testing using Qemu


## License

The MIT License (MIT)

Copyright (c) 2016-2020 Filippo Bergamasco.
Copyright (c) 2024 Lincă Marius Gheorghe.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
