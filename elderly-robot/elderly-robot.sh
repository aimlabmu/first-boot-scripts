#!/bin/bash -e

source ../common

## Go packages installation
three_dot_animate "installing go packages"

export cgo path for gmf
export CGO_CFLAGS="-I/usr/local/ffmpeg/include"
export CGO_LDFLAGS="-L/usr/local/ffmpeg/lib -lavcodec -lavutil -lavformat -lavdevice -lavfilter -lswresample -lswscale"

# install go dependencies
go get github.com/aimlabmu/gmf
go get github.com/aimlabmu/raylib-go/raylib
go get github.com/eclipse/paho.mqtt.golang
go get github.com/fogleman/gg

## Cloning elderly repo [input password required]
three_dot_animate "Cloning elderly repo [input password required]"

projDir=/home/pi/_projects/elderly-robot-server

if [ ! -d $projDir ]; then
  git clone https://tulakann@bitbucket.org/otalbs/elderly-robot-server.git $projDir
fi

## Install npm dependencies
three_dot_animate "Installing mqtt backend dependencies"

cd ~/_projects/elderly-robot-server/mqttBackend
if [ ! -d ~/_projects/elderly-robot-server/mqttBackend/node_modules ]; then
  npm install
fi

three_dot_animate "Installing node-ghk inside mqtt backend node modules"
# clone node-ghk recursively to the repo
if [ ! -d ~/_projects/elderly-robot-server/mqttBackend/node_modules/node-ghk ]; then
  cd ~/_projects/elderly-robot-server/mqttBackend/node_modules
  git clone --recursive https://github.com/aimlabmu/node-ghk.git

  replaceTarget='/home/pi/_projects/elderly-robot-server/mqttBackend/node_modules/node-ghk/libuiohook/src/x11/input_helper.c'
  sed -i '1876s/XkbGetKeyboard/XkbGetMap/' $replaceTarget
  echo "Replaced XkbGetKeyboard with XkbGetMap in $replaceTarget"

  echo "This requires proxy setup, please fill in the lines."
  read -p 'Username: ' usrV
  read -p 'Password: ' pwV

  export http_proxy="http://$usrV:$pwV@proxy-sa.mahidol:8080"
  echo "Proxy exported succesfully."

  three_dot_animate "Install node-ghk"
  # cd to node-ghk and install
  cd node-ghk && npm install

  # back to mqttbackend
  cd ..
fi

## build mqtt backend to be ready to run
three_dot_animate "Building mqtt backend"

cd ~/_projects/elderly-robot-server/mqttBackend/
npm run build

echo "DONE building mqtt backend."

## build goGUI to be ready to run
three_dot_animate "Building go GUI app"

cd ~/_projects/elderly-robot-server/gui/
go build -o build/gui

echo "DONE building go GUI."


## make mqtt backend work as a service
three_dot_animate "Installing mqttBackend service"

cd ~/_projects/elderly-robot-server/ServiceInstaller
npm install
sudo node installKeyboard.js
# add ExecStartPre=/bin/sleep 30 to mqttkeyboard.service
sudo sed -i 's/\[Service\]/\[Service\]\nExecStartPre=\/bin\/sleep 30/' /etc/systemd/system/mqttkeyboard.service
# enable service to let it auto start
sudo systemctl enable mqttkeyboard.service
echo "mqttkeyboard.service is enabled."

## install dependencies for video recorder/manager
three_dot_animate "Installing dependencies for videoRecorder and videoManager"

sudo apt-get install -y rabbitmq-server
sudo pip3 install Celery
go get -u golang.org/x/sys/...
go get github.com/fsnotify/fsnotify
go get github.com/jinzhu/gorm
go get github.com/mattn/go-sqlite3
echo "DONE installing videoManager dependencies."

## build video manager
three_dot_animate "Building video manager"

cd ~/_projects/elderly-robot-server/videoCapture/videoManager
go build -o build/videoManager

echo "DONE building videoManager."

## symlink mainScript.sh from elderly-robot-server to ~/_scripts and add to cronjob later
three_dot_animate "Symlinking mainScript.sh to ~/_scripts"
ln -s ~/_projects/elderly-robot-server/bashScripts/mainScript.sh ~/_scripts/mainScript.sh

echo "DONE symlinking."

## add cron job to start everything automatically
echo "From here you will need to do it yourself."
echo "But don't worry, we have a clue for you."
echo "---- FOCUS HERE ----"
echo "Run 'crontab -e' command and choose nano as editor."
echo "Then put following line in the bottom of the file:"
echo "'@reboot bash /home/pi/_scripts/mainScript.sh 2>> /home/pi/cronlog.txt'"
echo "--------------------"
echo "And finally reboot the robot, you should be good to go. Good Luck."