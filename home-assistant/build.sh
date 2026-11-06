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

apk add --no-cache patchelf
SNAP_ROOT=/snap/home-assistant/current/home-assistant
PYTHON=$(readlink -f ${BUILD_DIR}/usr/local/bin/python3)
patchelf \
  --set-interpreter ${SNAP_ROOT}$(patchelf --print-interpreter ${PYTHON}) \
  --force-rpath --set-rpath ${SNAP_ROOT}/usr/local/lib:${SNAP_ROOT}/usr/lib:${SNAP_ROOT}/lib \
  ${PYTHON}

sed -i '/import sys/a sys.executable = "/snap/home-assistant/current/home-assistant/bin/python"' ${BUILD_DIR}/usr/src/homeassistant/homeassistant/__main__.py

TURBOJPEG=$(ls ${BUILD_DIR}/usr/local/lib/python3.*/site-packages/turbojpeg.py)
sed -i 's#/opt/libjpeg-turbo/lib64/libturbojpeg.so#/snap/home-assistant/current/home-assistant/usr/lib/libturbojpeg.so.0#g' ${TURBOJPEG}

cp ${DIR}/python ${BUILD_DIR}/bin
cp ${DIR}/ffmpeg ${BUILD_DIR}/bin
cp ${DIR}/ffprobe ${BUILD_DIR}/bin
