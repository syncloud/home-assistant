#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )

BUILD_DIR=${DIR}/../build/snap/matter
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

for entry in /*; do
  case "${entry}" in
    /proc | /sys | /dev | /drone) continue ;;
  esac
  cp -a "${entry}" ${BUILD_DIR}/
done

rm -rf ${BUILD_DIR}/usr/share/doc
rm -rf ${BUILD_DIR}/usr/share/man
rm -f ${BUILD_DIR}/usr/bin/gdb

cp ${DIR}/bin/matter-server.sh ${BUILD_DIR}/bin

du -d1 -h ${BUILD_DIR} | sort -h | tail -20
