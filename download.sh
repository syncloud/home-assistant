#!/bin/bash -xe

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
VERSION=2021.3.4
DOWNLOAD_URL=https://github.com/syncloud/3rdparty/releases/download
ARCH=$(uname -m)
rm -rf ${DIR}/build
BUILD_DIR=${DIR}/build/snap
mkdir -p ${BUILD_DIR}

cd ${DIR}/build

apt update
apt -y install wget unzip

wget --progress=dot:giga ${DOWNLOAD_URL}/nginx/nginx-${ARCH}.tar.gz
tar xf nginx-${ARCH}.tar.gz
mv nginx ${BUILD_DIR}

wget --progress=dot:giga https://github.com/home-assistant/core/archive/refs/tags/${VERSION}.tar.gz
tar xf ${VERSION}.tar.gz
mv core-${VERSION} core-src

wget https://github.com/efficiosoft/ldap-auth-sh/archive/refs/heads/master.tar.gz
tar xf master.tar.gz
mv ldap-auth-sh-master ldap-auth-sh
