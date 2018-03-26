#!/bin/bash

# - - - - - - - - - - - - -
# - - - - - - - - - - - - -
# This script sets lirc up for Raspberry Pi.
# It is already included in aimrobot.sh script, however it can also be run separately.
# Note that only run this script on RPi because there is no OS detection.
# If you accidently ran this script on local, deleted the created files yourself. :|
# - - - - - - - - - - - - -
# - - - - - - - - - - - - -


# - - - - - - - -
# Helper Functions
# - - - - - - - -
# if_no_text_then_add <filename> <string> <text to add>
if_no_text_then_add() {
    if ! grep -R "$2" "$1"; 
    then 
        sudo tee -a "$1" << EOF
$3  
EOF
    else 
        echo "This string is already in a target file."
    fi
}

# replace_this_with_that <filename> <this> <that>
replace_this_with_that() {
    sudo sed -i "s/$2/$3/g" "$1"
    echo $3 is replaced with $2 in $1...
}

# function to print progress
echo_progress() {
    echo "[$(date)] $1"
    echo ""
}

# function to print horizontal line
echo_hr() {
    echo "# - - - - - - - - - - - - - -"
}

# mkdir if not exist
mkd_if_not_exist() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo_progress "path $1 is created."
    fi
}

# - - - - - - - -
# Starting Setup
# - - - - - - - -
echo_progress "start installing lirc"

# define variable
downloadPath="../downloaded-files"

# create path if not exist
mkd_if_not_exist $downloadPath

# download source from github
if [ ! -f $downloadPath/python3-lirc_1.2.1-1_armhf.deb ]; then
	wget "https://github.com/tompreston/python-lirc/releases/download/v1.2.1/python3-lirc_1.2.1-1_armhf.deb" -P $downloadPath
    echo_progress "python3-lirc_1.2.1-1_armhf.deb is downloaded."
fi

# install using dpkg
dpkg -i "$downloadPath/python3-lirc_1.2.1-1_armhf.deb"
echo_progress "python3-lirc_1.2.1-1_armhf.deb is installed."

# append lirc config to /etc/modules
if_no_text_then_add "/etc/modules" "lirc_rpi gpio_in_pin=4" "
lirc_dev
lirc_rpi gpio_in_pin=4" 
echo_progress "appended lirc config to /etc/modules"

# append another config to /etc/lirc/hardware.conf
if_no_text_then_add "/etc/lirc/hardware.conf" 'DEVICE="/dev/lirc0"' '
# Arguments which will be used when launching lircd
LIRCD_ARGS="--uinput --listen"

# Dont start lircmd even if there seems to be a good config file
# START_LIRCMD=false

# Dont start irexec, even if a good config file seems to exist.
# START_IREXEC=false

# Try to load appropriate kernel modules
LOAD_MODULES=true

# Run "lircd --driver=help" for a list of supported drivers.
DRIVER="default"

# usually /dev/lirc0 is the correct setting for systems using udev
DEVICE="/dev/lirc0"
MODULES="lirc_rpi"

# Default configuration files for your hardware if any
LIRCD_CONF=""
LIRCMD_CONF=""'
echo_progress "appended another config to /etc/lirc/hardware.conf"

# add lirc map gpio pin in /boot/config.txt
if_no_text_then_add "/boot/config.txt" "dtoverlay=lirc-rpi:gpio_in_pin=4" "
# lirc
dtoverlay=lirc-rpi:gpio_in_pin=4"
echo_progress "added lirc map gpio pin in /boot/config.txt"

# append lirc options
if_no_text_then_add "/boot/config.txt" "device    = /dev/lirc0" '
driver    = default
device    = /dev/lirc0'
echo_progress "appended lirc options."

# IR keys
if [ ! -f $downloadPath/lirc_configs.zip ]; then
	wget "https://www.dropbox.com/s/08xttu8vaad2qn0/lirc_configs.zip" -P $downloadPath
    unzip $downloadPath/lirc_configs.zip -d $downloadPath/lirc_configs
    echo_progress "lirc_configs.zip is downloaded."
fi

# copy settings to place
sudo cp $downloadPath/lirc_configs/lircd.conf "/etc/lirc/lircd.conf"
echo_progress "$downloadPath/lirc_configs/lircd.conf is copied to /etc/lirc/lircd.conf"
cp $downloadPath/lirc_configs/lircrc "/home/pi/.lircrc"
echo_progress "$downloadPath/lirc_configs/lircrc is copied to /home/pi/.lircrc"
sudo cp $downloadPath/lirc_configs/lircrc "/etc/lirc/lircrc"
echo_progress "$downloadPath/lirc_configs/lircrc is copied to /etc/lirc/lircrc"

# change files permission
chmod 777 "/home/pi/.lircrc"
sudo chmod 777 "/etc/lirc/lircrc"
sudo chmod 777 "/etc/lirc/lircd.conf"
echo_progress "lirc config files permission are changed."

# ###########################################################################################