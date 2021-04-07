#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
mkdir -p ${DIR}/build/bin
apt install libncurses5

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
sed 's|VIRTUAL_ENV=.*|VIRTUAL_ENV=/snap/home-assistant/home-assistant|g' ${DIR}/build/home-assistant/bin/activate
sed 's|#!.*/bin/python|/snap/home-assistant/current/python/bin/python|g' ${DIR}/build/home-assistant/bin/hass
