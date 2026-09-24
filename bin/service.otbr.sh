#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

DEVICE_FILE=$SNAP_DATA/otbr/device
BAUDRATE_FILE=$SNAP_DATA/otbr/baudrate

announced=""
while true; do
  device=$(cat ${DEVICE_FILE} 2>/dev/null || true)
  if [ -n "${device}" ] && [ -e "${device}" ]; then
    break
  fi
  if [ -z "${announced}" ]; then
    echo "thread radio not configured, waiting: write the serial device path to ${DEVICE_FILE}, for example /dev/ttyUSB0"
    announced=yes
  fi
  sleep 30
done

baudrate=$(cat ${BAUDRATE_FILE} 2>/dev/null || echo 460800)
backbone=$(ip -o -4 route show to default | awk '{print $5}' | head -1)

echo "starting thread border router on ${device} at ${baudrate} baud, backbone ${backbone}"

exec ${DIR}/otbr/bin/otbr-agent.sh \
  -I wpan0 \
  -B ${backbone} \
  -d 5 \
  -s \
  --data-path $SNAP_DATA/otbr \
  --rest-listen-address 127.0.0.1 \
  --rest-listen-port 8081 \
  "spinel+hdlc+uart://${device}?uart-baudrate=${baudrate}"
