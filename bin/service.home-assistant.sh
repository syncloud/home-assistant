#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

export PATH=$PATH:${DIR}/python/bin
export LD_LIBRARY_PATH=$PATH:${DIR}/python/lib
source ${DIR}/home-assistant/bin/activate
exec ${DIR}/python/bin/python -m homeassistant --config $SNAP_DATA
