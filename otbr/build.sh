#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )

BUILD_DIR=${DIR}/../build/snap/otbr
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/usr/lib ${BUILD_DIR}/usr/sbin ${BUILD_DIR}/etc

cp -a /lib ${BUILD_DIR}/
cp -a /usr/lib/*-linux-gnu* ${BUILD_DIR}/usr/lib/
cp -a /usr/sbin/otbr-agent ${BUILD_DIR}/usr/sbin/
cp -a /usr/sbin/ot-ctl ${BUILD_DIR}/usr/sbin/
cp -a /etc/dbus-1 ${BUILD_DIR}/etc/

find ${BUILD_DIR} -name "*.a" -delete
rm -rf ${BUILD_DIR}/usr/lib/*/perl*
rm -rf ${BUILD_DIR}/usr/lib/*/libicu*

mkdir -p ${BUILD_DIR}/bin
cp ${DIR}/bin/otbr-agent.sh ${BUILD_DIR}/bin
cp ${DIR}/bin/ot-ctl.sh ${BUILD_DIR}/bin

du -d1 -h ${BUILD_DIR} | sort -h | tail -20
