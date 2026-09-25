#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

ADAPTER_FILE=$SNAP_DATA/matter/bluetooth-adapter

adapter=$(cat ${ADAPTER_FILE} 2>/dev/null || true)
if [ -z "${adapter}" ]; then
  for hci in /sys/class/bluetooth/hci*; do
    if [ -e "${hci}" ]; then
      adapter=${hci##*/hci}
      break
    fi
  done
fi

bluetooth=""
if [ -n "${adapter}" ] && [ "${adapter}" != "none" ]; then
  echo "using bluetooth adapter hci${adapter} for matter commissioning"
  bluetooth="--bluetooth-adapter ${adapter}"
else
  echo "no bluetooth adapter, matter commissioning will be network-only"
fi

exec ${DIR}/matter/bin/matter-server.sh \
  --storage-path $SNAP_DATA/matter \
  --paa-root-cert-dir $SNAP_DATA/matter/credentials \
  --listen-address 127.0.0.1 \
  --port 5580 \
  ${bluetooth}
