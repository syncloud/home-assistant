#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

exec ${DIR}/home-assistant/bin/python ${DIR}/home-assistant/bin/hass --config $SNAP_DATA/ha.config
