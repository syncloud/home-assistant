#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

mkdir -p ${DIR}/build/bin

#${DIR}/build/python/bin/pip install -r ${DIR}/requirements.txt

#${DIR}/build/python/bin/pip install -r ${DIR}/build/home-assistant/requirements_all.txt
#${DIR}/build/python/bin/python ${DIR}/build/home-assistant/setup.py install

${DIR}/build/python/bin/pip install home-assistant