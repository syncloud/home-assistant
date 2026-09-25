#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap/otbr

${BUILD_DIR}/bin/otbr-agent.sh --version
${BUILD_DIR}/bin/otbr-agent.sh --help 2>&1 | grep -q rest-listen-address
grep -q "unix socket" ${BUILD_DIR}/usr/sbin/otbr-agent
${BUILD_DIR}/bin/ot-ctl.sh state 2>&1 | grep -q "connect session failed"
