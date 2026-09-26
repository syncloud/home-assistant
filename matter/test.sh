#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap/matter

${BUILD_DIR}/bin/matter-server.sh --help | grep -q listen-address
${BUILD_DIR}/bin/matter-server.sh --help | grep -q bluetooth-adapter
grep -q "listenTarget" ${BUILD_DIR}/app/node_modules/matter-server/dist/esm/server/WebServer.js
