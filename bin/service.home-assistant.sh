#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

DEPS=$SNAP_DATA/ha.config/deps
mkdir -p ${DEPS}

export PYTHONPATH=${DEPS}
export UV_PYTHON=${DIR}/home-assistant/bin/python
export UV_EXTRA_INDEX_URL=https://wheels.home-assistant.io/musllinux-index/
export UV_NO_CACHE=true

exec ${DIR}/home-assistant/bin/python -m homeassistant --config $SNAP_DATA/ha.config
