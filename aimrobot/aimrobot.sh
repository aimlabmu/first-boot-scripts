#!/bin/bash -e

source ../common

# install required package
sudo apt-get install liblirc-dev

## Cloning meedee-rpi repo [input password required]
three_dot_animate "Cloning/Pulling meedee-rpi [input password required]"

projDir=/home/pi/_projects/meedee-rpi

if [ ! -d $projDir ]; then
  git clone -b rpi-testing https://tulakann@bitbucket.org/otalbs/meedee-rpi.git $projDir
else 
  cd $projDir
  git pull origin master
fi

# cd $projDir/systems-server
# npm install && npm run build

# cd $projDir/robot-display
# npm install && npm run package-linux

# cd $projDir/web-server
# npm install
