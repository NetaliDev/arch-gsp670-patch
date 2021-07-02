#!/bin/bash

VER=$(uname -r | awk -F "-" '{print $1}')
DIR=linux-$VER
FILENAME=$DIR.tar.xz

echo "downloading"
curl -O https://cdn.kernel.org/pub/linux/kernel/v5.x/$FILENAME
echo "unpacking"
tar -xJf $FILENAME

cd $DIR

echo "make mrproper"
make mrproper

echo "copying config"
cp /usr/lib/modules/$(uname -r)/build/.config ./
cp /usr/lib/modules/$(uname -r)/build/Module.symvers ./

echo "make modules_prepare"
make EXTRAVERSION=-arch1-1 modules_prepare

echo "installing patch"
patch -p1 -i ../gsp670.patch

echo "building module"
make M=sound/usb

echo "compressing module"
xz -f sound/usb/snd-usb-audio.ko

echo "unloading modules"
sudo modprobe -r snd_usb_audio
sudo modprobe -r snd_usbmidi_lib

echo "backing up old module"
cp /usr/lib/modules/$(uname -r)/kernel/sound/usb/snd-usb-audio.ko.xz snd-usb-audio.ko.xz.backup

echo "installing new module"
sudo cp -f sound/usb/snd-usb-audio.ko.xz /usr/lib/modules/$(uname -r)/kernel/sound/usb/

echo "loading new modules"
sudo modprobe snd_usbmidi_lib
sudo modprobe snd_usb_audio

echo "done"
