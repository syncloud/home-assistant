#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

export LD_LIBRARY_PATH=$PATH:${DIR}/python/lib:PATH:${DIR}/python/lib64
source ${DIR}/home-assistant/bin/activate
exec python ${DIR}/home-assistant/bin/hass --config $SNAP_DATA/ha.config
