#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

exec ${DIR}/matter/bin/matter-server.sh \
  --storage-path $SNAP_DATA/matter \
  --paa-root-cert-dir $SNAP_DATA/matter/credentials \
  --listen-address 127.0.0.1 \
  --port 5580
