#!/bin/bash

VER=$(uname -r | awk -F "-" '{print $1}')
DIR=linux-$VER
FILENAME=$DIR.tar.xz

export MAKEFLAGS="-j $(nproc)"

lsusb | grep "GSP 670" > /dev/null
HEADSET_CONNECTED=$?

lsusb | grep "GSA 70" > /dev/null
DONGLE_CONNECTED=$?

if [ $HEADSET_CONNECTED -eq 0 ]
then
    echo "The GSP 670 Headset is still connected --> please disconnect it and try again!"
    exit 1
fi

if [ $DONGLE_CONNECTED -eq 0 ]
then
    echo "The GSA 70 Dongle is still connected --> please disconnect it and try again!"
    exit 1
fi

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

# cut out extra-version string
EV_PARTS=()

for part in $(uname -r | tr "-" "\n")
do
    EV_PARTS+=($part)
done

EV_STRING="-${EV_PARTS[1]}-${EV_PARTS[2]}"

echo "make modules_prepare"
make EXTRAVERSION=$EV_STRING modules_prepare

echo "installing patch"
patch -p1 -i ../gsp670.patch

echo "building module"
make M=sound/usb

echo "compressing module"
zstd sound/usb/snd-usb-audio.ko

echo "unloading modules"
sudo modprobe -r snd_usb_audio
sudo modprobe -r snd_usbmidi_lib

echo "backing up old module"
BACKUP_DIR=../backups/$(uname -r)
mkdir -p $BACKUP_DIR
cp /usr/lib/modules/$(uname -r)/kernel/sound/usb/snd-usb-audio.ko.zst $BACKUP_DIR/snd-usb-audio.ko.zst.backup

echo "installing new module"
sudo cp -f sound/usb/snd-usb-audio.ko.zst /usr/lib/modules/$(uname -r)/kernel/sound/usb/

echo "loading new modules"
sudo modprobe snd_usbmidi_lib
sudo modprobe snd_usb_audio

echo "done"
