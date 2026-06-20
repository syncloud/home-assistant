#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )

BUILD_DIR=${DIR}/../build/snap/home-assistant
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

for entry in /*; do
  case "${entry}" in
    /proc | /sys | /dev | /drone) continue ;;
  esac
  cp -a "${entry}" ${BUILD_DIR}/
done

sed -i '/import sys/a sys.executable = "/snap/home-assistant/current/home-assistant/bin/python"' ${BUILD_DIR}/usr/src/homeassistant/homeassistant/__main__.py

TURBOJPEG=$(ls ${BUILD_DIR}/usr/local/lib/python3.*/site-packages/turbojpeg.py)
sed -i 's#/opt/libjpeg-turbo/lib64/libturbojpeg.so#/snap/home-assistant/current/home-assistant/usr/lib/libturbojpeg.so.0#g' ${TURBOJPEG}

cp ${DIR}/python ${BUILD_DIR}/bin
cp ${DIR}/ffmpeg ${BUILD_DIR}/bin
cp ${DIR}/ffprobe ${BUILD_DIR}/bin
