#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
apt update
apt install -y libltdl7 libnss3

BUILD_DIR=${DIR}/../build/snap/home-assistant
docker ps -a -q --filter ancestor=home-assistant:syncloud --format="{{.ID}}" | xargs docker stop | xargs docker rm || true
docker rmi home-assistant:syncloud || true
docker build -t home-assistant:syncloud .
docker create --name=home-assistant home-assistant:syncloud
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
docker export home-assistant -o app.tar
docker ps -a -q --filter ancestor=home-assistant:syncloud --format="{{.ID}}" | xargs docker stop | xargs docker rm || true
docker rmi home-assistant:syncloud || true
tar xf app.tar
rm -rf app.tar
sed -i '#import sys#a sys.executable = /snap/home-assistant/current/home-assistant/bin/python' ${BUILD_DIR}/usr/src/homeassistant/homeassistant/__main__.py
cp ${DIR}/python ${BUILD_DIR}/bin/
