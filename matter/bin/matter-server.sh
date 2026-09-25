#!/bin/bash -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

LIBS=$(echo ${DIR}/lib/*-linux-gnu*)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/*-linux-gnu*)

exec ${DIR}/lib/*-linux-gnu*/ld-linux-*.so.* --library-path $LIBS \
  ${DIR}/usr/local/bin/node ${DIR}/app/node_modules/matter-server/dist/esm/MatterServer.js "$@"
