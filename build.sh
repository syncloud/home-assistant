#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#VERSION=2021.3.4
mkdir -p ${DIR}/build/bin

${DIR}/build/python/bin/pip install -r ${DIR}/requirements.txt
cd ${DIR}/build
${DIR}/build/python/bin/python -m venv home-assistant
export LD_LIBRARY_PATH=${DIR}/build/python/lib
sed -i 's/include-system-site-packages = false/include-system-site-packages = true/g' home-assistant/pyvenv.cfg
source home-assistant/bin/activate
cd ${DIR}/build/core-src
pip install wheel Cython --constraint homeassistant/package_constraints.txt
pip install -r requirements_all.txt --constraint homeassistant/package_constraints.txt
python setup.py install
sed 's|VIRTUAL_ENV=.*|VIRTUAL_ENV=/snap/home-assistant/home-assistant|g' home-assistant/bin/activate
sed 's|#!.*/bin/python|/snap/home-assistant/current/python/bin/python|g' home-assistant/bin/hass
