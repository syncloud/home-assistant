#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap/home-assistant
$BUILD_DIR/bin/python --version
$BUILD_DIR/bin/ffmpeg --help
$BUILD_DIR/bin/ffprobe --help

COMPONENTS=${BUILD_DIR}/usr/src/homeassistant/homeassistant/components
for component in tuya speedtestdotnet; do
  test -f ${COMPONENTS}/${component}/manifest.json
done

$BUILD_DIR/bin/python -c "import tuya_sharing"
$BUILD_DIR/bin/python -c "import speedtest"
$BUILD_DIR/bin/python -c "from importlib.metadata import version; print('tuya-device-sharing-sdk', version('tuya-device-sharing-sdk')); print('speedtest-cli', version('speedtest-cli'))"

CLIENT=$(echo ${BUILD_DIR}/usr/local/lib/python3.*/site-packages)/matter_server/client/connection.py
grep -q "UnixConnector" ${CLIENT}
grep -q "unix:///var/snap/home-assistant/current/matter.socket" ${BUILD_DIR}/usr/src/homeassistant/homeassistant/components/matter/config_flow.py
grep -q "unix:///var/snap/home-assistant/current/otbr.socket" ${BUILD_DIR}/usr/src/homeassistant/homeassistant/components/otbr/config_flow.py

SNAP_DIR=${DIR}/../build/snap
find ${SNAP_DIR}/custom_components/hacs -name manifest.json | grep -q manifest.json

set +e
echo "=== speedtest cli run (non-gating) ==="
$BUILD_DIR/bin/python -m speedtest --simple
echo "speedtest exit=$?"
set -e
