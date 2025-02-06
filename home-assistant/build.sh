#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap/home-assistant
while ! docker build -t python:syncloud . ; do
  echo "retry docker"
  sleep 1
done
docker build -t home-assistant:syncloud .
docker create --name=home-assistant home-assistant:syncloud
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
docker export home-assistant -o app.tar

tar xf app.tar
rm -rf app.tar
sed -i '/import sys/a sys.executable = "/snap/home-assistant/current/home-assistant/bin/python"' ${BUILD_DIR}/usr/src/homeassistant/homeassistant/__main__.py

sed -i 's#/opt/libjpeg-turbo/lib64/libturbojpeg.so#/snap/home-assistant/current/home-assistant/usr/lib/libturbojpeg.so.0#g' ${BUILD_DIR}/usr/local/lib/python3.13/site-packages/turbojpeg.py

cp ${DIR}/python ${BUILD_DIR}/bin
cp ${DIR}/ffmpeg ${BUILD_DIR}/bin
cp ${DIR}/ffprobe ${BUILD_DIR}/bin
