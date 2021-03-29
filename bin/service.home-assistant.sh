#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

exec ${DIR}/python/bin/hass --config $SNAP_DATA