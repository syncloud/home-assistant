#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap/matter

${BUILD_DIR}/bin/matter-server.sh --help | grep -q listen-address
test -d ${BUILD_DIR}/usr/local/lib/python3.12/site-packages/chip
test -f ${BUILD_DIR}/etc/ssl/certs/ca-certificates.crt
