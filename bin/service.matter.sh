#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

/bin/rm -f $SNAP_DATA/matter.socket

exec ${DIR}/matter/bin/matter-server.sh \
  --storage-path $SNAP_DATA/matter \
  --listen-address $SNAP_DATA/matter.socket \
  --bluetooth-adapter 0
