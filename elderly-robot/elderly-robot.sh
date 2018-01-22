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

if [ ! -d projDir ]; then
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

  echo "This requires proxy setup, please fill in the lines."
  read -p 'Username: ' usrV
  read -p 'Password: ' pwV

  export http_proxy="http://$usrV:$pwV@proxy-sa.mahidol:8080"
  echo "Proxy exported succesfully."

  # cd to node-ghk and install
  cd node-ghk && npm install

  # back to mqttbackend
  cd ..
fi