#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )

BUILD_DIR=${DIR}/../build/snap/matter
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/usr/local/bin ${BUILD_DIR}/usr/lib ${BUILD_DIR}/bin

cp -a /app ${BUILD_DIR}/
cp -a /usr/local/bin/node ${BUILD_DIR}/usr/local/bin/
cp -a /lib ${BUILD_DIR}/
cp -a /usr/lib/*-linux-gnu* ${BUILD_DIR}/usr/lib/

find ${BUILD_DIR}/app -name "*.map" -delete
rm -rf ${BUILD_DIR}/usr/lib/*/perl*
rm -rf ${BUILD_DIR}/usr/lib/*/libicu*
find ${BUILD_DIR} -name "*.a" -delete

node ${DIR}/patch.cjs ${BUILD_DIR}

cp ${DIR}/bin/matter-server.sh ${BUILD_DIR}/bin

du -d1 -h ${BUILD_DIR} | sort -h | tail -20
