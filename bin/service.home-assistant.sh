#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

#export PATH=$PATH:${DIR}/python/bin
export LD_LIBRARY_PATH=$PATH:${DIR}/python/lib:PATH:${DIR}/python/lib64
source ${DIR}/home-assistant/bin/activate
#export PYTHONPATH=/snap/home-assistant/current/home-assistant/lib/python3.8/site-packages
exec python ${DIR}/home-assistant/bin/hass --config $SNAP_DATA
