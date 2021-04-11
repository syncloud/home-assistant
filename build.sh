#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
WHEELS_LINKS=https://wheels.home-assistant.io/alpine-3.12/$(dpkg-architecture -q DEB_HOST_ARCH)/
apt update
apt install -y libncurses5 libudev-dev build-essential musl
${DIR}/build/python/bin/pip install -r ${DIR}/requirements.txt

mkdir -p /snap/home-assistant/current
mv ${DIR}/build/python /snap/home-assistant/current
cd /snap/home-assistant/current
./python/bin/python -m venv home-assistant
export LD_LIBRARY_PATH=/snap/home-assistant/current/python/lib
sed -i 's/include-system-site-packages = false/include-system-site-packages = true/g' home-assistant/pyvenv.cfg
source home-assistant/bin/activate
cd ${DIR}/build/core-src
pip install wheel Cython --constraint homeassistant/package_constraints.txt
pip install --no-cache-dir --no-index --only-binary=:all: --find-links ${WHEELS_LINKS} -r requirements_all.txt --constraint homeassistant/package_constraints.txt
pip install .
cd /snap/home-assistant/current
python -c "import homeassistant"
python -c "import asyncio"
mv /snap/home-assistant/current/python ${DIR}/build
mv /snap/home-assistant/current/home-assistant ${DIR}/build

cp /lib/ld-musl-*.so* ${DIR}/build/python/lib
#find ${DIR}/build -name "*musl"'
#sed -i 's|VIRTUAL_ENV=.*|VIRTUAL_ENV=/snap/home-assistant/current/home-assistant|g' ${DIR}/build/home-assistant/bin/activate
find ${DIR}/build/home-assistant -type f -executable -exec sed -i 's|#!.*/bin/python.*|#!/snap/home-assistant/current/python/bin/python|g' {} \;
sed -i 's|home.*|home = /snap/home-assistant/current/python/bin|g' ${DIR}/build/home-assistant/pyvenv.cfg
#rm ${DIR}/build/home-assistant/bin/python3
#ln -s /snap/home-assistant/current/python/bin/python ${DIR}/build/home-assistant/bin/python3
