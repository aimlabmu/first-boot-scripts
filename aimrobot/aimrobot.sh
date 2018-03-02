#!/bin/bash -e

source ../common

## Cloning meedee-rpi repo [input password required]
three_dot_animate "Cloning meedee-rpi repo [input password required] / or pull if the repo exists"

projDir=/home/pi/_projects/meedee-rpi

if [ ! -d $projDir ]; then
  git clone -b rpi-testing https://tulakann@bitbucket.org/otalbs/meedee-rpi.git $projDir
else 
  cd $projDir
  git pull origin master
fi

# log 'building systems-server'
cd $projDir/systems-server
npm install && npm run build

# log 'building robot display'
cd $projDir/robot-display
npm install && npm run package-linux

# log 'building web server'
cd $projDir/web-server
npm install