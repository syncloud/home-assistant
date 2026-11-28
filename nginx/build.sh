#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap/nginx
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
cp -a /etc ${BUILD_DIR}
cp -a /usr ${BUILD_DIR}
cp -a /bin ${BUILD_DIR}
cp -a /lib ${BUILD_DIR}
cp -r ${DIR}/bin/* ${BUILD_DIR}/bin
