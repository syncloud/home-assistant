#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT=$( cd "${DIR}/.." && pwd )
cd ${ROOT}

ESM=build/snap/matter/app/node_modules/matter-server/dist/esm

git apply --directory="${ESM}" patches/matter-server-unix-socket.patch
