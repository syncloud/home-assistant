#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

export PATH=$PATH:${DIR}/python/bin
export LD_LIBRARY_PATH=$PATH:${DIR}/python/lib
source ${DIR}/home-assistant/bin/activate
exec ${DIR}/home-assistant/bin/hass --config $SNAP_DATA
