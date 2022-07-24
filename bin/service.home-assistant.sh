#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

exec ${DIR}/home-assistant/bin/python -m homeassistant --config $SNAP_DATA/ha.config
