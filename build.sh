#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
mkdir -p ${DIR}/build/bin
WHEELS_LINKS=https://wheels.home-assistant.io/alpine-3.12/$(dpkg-architecture -q DEB_HOST_ARCH)/
apt update
apt install -y libncurses5 libudev-dev build-essential

${DIR}/build/python/bin/pip install -r ${DIR}/requirements.txt
cd ${DIR}/build
${DIR}/build/python/bin/python -m venv home-assistant
export LD_LIBRARY_PATH=${DIR}/build/python/lib
sed -i 's/include-system-site-packages = false/include-system-site-packages = true/g' home-assistant/pyvenv.cfg
source home-assistant/bin/activate
cd ${DIR}/build/core-src
pip install wheel Cython --constraint homeassistant/package_constraints.txt
pip install --no-cache-dir --no-index --only-binary=:all: --find-links ${WHEELS_LINKS} -r requirements_all.txt --constraint homeassistant/package_constraints.txt
python setup.py install
sed -i 's|VIRTUAL_ENV=.*|VIRTUAL_ENV=/snap/home-assistant/home-assistant|g' ${DIR}/build/home-assistant/bin/activate
sed -i 's|#!.*/bin/python|#!/snap/home-assistant/current/python/bin/python|g' ${DIR}/build/home-assistant/bin/hass
sed -i 's|home.*|home = /snap/home-assistant/current/python/bin|g' ${DIR}/build/home-assistant/pyvenv.cfg
rm ${DIR}/build/home-assistant/bin/python3
ln -s /snap/home-assistant/current/python/bin/python3 ${DIR}/build/home-assistant/bin/python3
