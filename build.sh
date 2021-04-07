#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#VERSION=2021.3.4
mkdir -p ${DIR}/build/bin

${DIR}/build/python/bin/pip install -r ${DIR}/requirements.txt
cd ${DIR}/build
${DIR}/build/python/bin/python -m venv home-assistant
export LD_LIBRARY_PATH=${DIR}/build/python/lib
source home-assistant/bin/activate
cd ${DIR}/build/core-src
pip install wheel Cython --constraint homeassistant/package_constraints.txt
pip install -r requirements_all.txt --constraint homeassistant/package_constraints.txt
python setup.py install
