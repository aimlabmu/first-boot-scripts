#!/bin/bash -e

source ../common

## define path
projDir=/home/pi/_projects/meedee-rpi

## install required package
three_dot_animate "Installing dependencies"
# lirc
sudo apt-get install -y liblirc-dev
# bleno
sudo apt-get install -y bluetooth bluez libbluetooth-dev libudev-dev libudev-dev
# setting permission for bleno
sudo setcap cap_net_raw+eip $(eval readlink -f `which node`)

## Cloning or pulling meedee-rpi repo [input password required]
if [ ! -d $projDir ]; then
  three_dot_animate "Cloning meedee-rpi [input password required]"
  git clone -b rpi-testing https://tulakann@bitbucket.org/otalbs/meedee-rpi.git $projDir
else 
  cd $projDir
  three_dot_animate "Pulling meedee-rpi [input password required]"
  git pull origin master
fi

## Should add compilation stuffs here
## cd to meedee-rpi/bashScripts and run ./configure build-rpi upload-content