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

echo "DONE building mqtt backend"

## build goGUI to be ready to run
three_dot_animate "Building go GUI app"

cd ~/_projects/elderly-robot-server/gui/
go build -o build/gui

echo "DONE building go GUI"

## make mqtt backend work as a service
## configure mqtt service
## add cron job to start everything automatically
## install dependencies for video recorder/manager
## build video manager
sudo apt-get install rabbitmq-server
sudo pip3 install Celery

go get -u golang.org/x/sys/...
go get github.com/fsnotify/fsnotify
go get github.com/jinzhu/gorm
go get github.com/mattn/go-sqlite3

go build *

./videoManager
```