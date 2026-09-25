#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

FORK=https://github.com/syncloud/ot-br-posix
REF=ea1df5f633d794b46aa44e5622a65afcc4741d7c

BUILD_DIR=${DIR}/../build/snap/otbr
SRC_DIR=${DIR}/../build/otbr-src

rm -rf ${BUILD_DIR} ${SRC_DIR}
mkdir -p ${BUILD_DIR}/usr/sbin ${BUILD_DIR}/usr/lib ${BUILD_DIR}/bin

${DIR}/../apt.sh git ca-certificates lsb-release sudo

git init -q ${SRC_DIR}
cd ${SRC_DIR}
git remote add origin ${FORK}
git fetch -q --depth 1 origin ${REF}
git checkout -q FETCH_HEAD
git submodule update -q --init --depth 1 --recursive

DEBIAN_FRONTEND=noninteractive ./script/bootstrap
./script/cmake-build -DOTBR_REST=ON -DOTBR_WEB=OFF -DOTBR_BORDER_ROUTING=ON

cp -a ${SRC_DIR}/build/otbr/src/agent/otbr-agent ${BUILD_DIR}/usr/sbin/
cp -a ${SRC_DIR}/build/otbr/third_party/openthread/repo/src/posix/ot-ctl ${BUILD_DIR}/usr/sbin/

cp -a /lib ${BUILD_DIR}/
cp -a /usr/lib/*-linux-gnu* ${BUILD_DIR}/usr/lib/

find ${BUILD_DIR} -name "*.a" -delete
rm -rf ${BUILD_DIR}/usr/lib/*/perl*
rm -rf ${BUILD_DIR}/usr/lib/*/libicu*

cp ${DIR}/bin/otbr-agent.sh ${BUILD_DIR}/bin
cp ${DIR}/bin/ot-ctl.sh ${BUILD_DIR}/bin

rm -rf ${SRC_DIR}

du -d1 -h ${BUILD_DIR} | sort -h | tail -20
