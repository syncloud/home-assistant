#!/bin/bash -xe

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
VERSION=2021.3.4
DOWNLOAD_URL=https://github.com/syncloud/3rdparty/releases/download/1
ARCH=$(uname -m)
rm -rf ${DIR}/build
BUILD_DIR=${DIR}/build
mkdir -p ${BUILD_DIR}

cd $BUILD_DIR

wget --progress=dot:giga ${DOWNLOAD_URL}/python-${ARCH}.tar.gz
tar xf python-${ARCH}.tar.gz

wget --progress=dot:giga ${DOWNLOAD_URL}/nginx-${ARCH}.tar.gz
tar xf nginx-${ARCH}.tar.gz

wget --progress=dot:giga https://github.com/home-assistant/core/archive/refs/tags/${VERSION}.tar.gz
tar xf ${VERSION}.tar.gz
mv ${VERSION} home-assistant