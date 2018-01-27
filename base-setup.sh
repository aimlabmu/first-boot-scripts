#!/bin/bash -e

source ./common

# pull the latest update of this repo
git pull origin master

## raspi-config
echo 'Please set these up:
  - Boot Options
    - Console Autologin
  - Interfacing Options
    - Disable Serial
    - Enable SSH, I2C
  - Advanced Options
    - Expand Filesystem
  - Localisation/Internationalisation Options
    - Change keyboard layout
      - Keyboard Layout > Generic 101 > Other > en-US > en-US > OK
      - Will have to reboot to see change.'

sleep 5

sudo raspi-config

## set gpio pin for UART
three_dot_animate "Next we will set GPIO pins for you"

gpio mode 15 ALT0; gpio mode 16 ALT0

three_dot_animate "We will also set 'enable_uart' in /boot/config.txt just in case it is not enable yet"

sudo sed -i 's/enable_uart=0/enable_uart=1/g' /boot/config.txt

echo "Done, set values: "
gpio readall | head -n 8

## default sounds
three_dot_animate "Settings default sound values"

amixer cset numid=1 100%
sudo alsactl store

echo "Done, set values: "
cat /var/lib/alsa/asound.state | grep -A 13 control.1