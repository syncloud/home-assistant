#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
WHEELS_LINKS=https://wheels.home-assistant.io/alpine-3.12/$(dpkg-architecture -q DEB_HOST_ARCH)/
apt update
apt install -y libncurses5 libudev-dev build-essential musl cmake libtool-bin groff
${DIR}/build/python/bin/pip install -r ${DIR}/requirements.txt

cd ${DIR}/build
wget https://github.com/mvanderkolff/jbigkit-packaging/archive/refs/tags/debian/2.1-3.tar.gz
tar xf 2.1-3.tar.gz
cd jbigkit-packaging-debian-2.1-3
for i in debian/patches/*.diff; do patch -p1 < $i; done
make
cp libjbig/.libs/*.so* ${DIR}/build/python/lib

cd ${DIR}/build
wget https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-0.5.2.tar.gz
tar xf libwebp-0.5.2.tar.gz
cd libwebp-0.5.2
./configure --prefix=${DIR}/build/python
make -j4
make install

cd ${DIR}/build
wget https://download.osgeo.org/libtiff/tiff-4.2.0.tar.gz
tar xf tiff-4.2.0.tar.gz
cd tiff-4.2.0
./configure --prefix=${DIR}/build/python
make -j4
make install

cd ${DIR}/build
wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/2.0.6.tar.gz
tar xf 2.0.6.tar.gz
cd libjpeg-turbo-2.0.6
cmake -DCMAKE_INSTALL_PREFIX=${DIR}/build/python -DWITH_JPEG8=1
make -j4
make install

cd ${DIR}/build
wget https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz
tar xf libffi-3.3.tar.gz
cd libffi-3.3
./configure --prefix=${DIR}/build/python
make -j4
make install

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
cp /lib/*-linux-musl*/libc.so ${DIR}/build/python/lib/libc.musl-$(uname -m).so.1

cp /usr/lib/*/libcrypto.so* ${DIR}/build/python/lib
cp /usr/lib/*/libssl.so* ${DIR}/build/python/lib
#cp /usr/lib/*/libjpeg.so* ${DIR}/build/python/lib

#find ${DIR}/build -name "*musl"'
#sed -i 's|VIRTUAL_ENV=.*|VIRTUAL_ENV=/snap/home-assistant/current/home-assistant|g' ${DIR}/build/home-assistant/bin/activate
find ${DIR}/build/home-assistant -type f -executable -exec sed -i 's|#!.*/bin/python.*|#!/snap/home-assistant/current/python/bin/python|g' {} \;
sed -i 's|home.*|home = /snap/home-assistant/current/python/bin|g' ${DIR}/build/home-assistant/pyvenv.cfg
#rm ${DIR}/build/home-assistant/bin/python3
#ln -s /snap/home-assistant/current/python/bin/python ${DIR}/build/home-assistant/bin/python3

