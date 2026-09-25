#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

DEVICE_FILE=$SNAP_DATA/otbr/device
BAUDRATE_FILE=$SNAP_DATA/otbr/baudrate

device=$(cat ${DEVICE_FILE} 2>/dev/null || true)
if [ -z "${device}" ]; then
  echo "thread radio not configured: write the serial device path to ${DEVICE_FILE}, for example /dev/ttyUSB0, then snap restart home-assistant.otbr"
  exit 0
fi

baudrate=$(cat ${BAUDRATE_FILE} 2>/dev/null || echo 460800)
backbone=$(ip -o -4 route show to default | awk '{print $5}' | head -1)

echo "starting thread border router on ${device} at ${baudrate} baud, backbone ${backbone}"

/bin/rm -f $SNAP_DATA/otbr.socket

exec ${DIR}/otbr/bin/otbr-agent.sh \
  -I wpan0 \
  -B ${backbone} \
  -d 5 \
  -s \
  --vendor-name Syncloud \
  --model-name HomeAssistant \
  --data-path $SNAP_DATA/otbr \
  --rest-listen-address $SNAP_DATA/otbr.socket \
  "spinel+hdlc+uart://${device}?uart-baudrate=${baudrate}"
