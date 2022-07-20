#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
WHEELS_LINKS=https://wheels.home-assistant.io/alpine-3.12/$(dpkg --print-architecture)/
apt update
apt install -y libncurses5 libudev-dev build-essential musl cmake libtool-bin groff wget
pip install -r /requirements.txt
cd /core-src
pip install setuptools==57.5.0
pip install -r requirements.txt
pip install -r requirements_all.txt
PREFIX=/snap/home-assistant/current
mkdir -p $PREFIX

mkdir ${DIR}/build
cd ${DIR}/build
wget https://github.com/mvanderkolff/jbigkit-packaging/archive/refs/tags/debian/2.1-3.tar.gz
tar xf 2.1-3.tar.gz
cd jbigkit-packaging-debian-2.1-3
for i in debian/patches/*.diff; do patch -p1 < $i; done
make
make install
#cp libjbig/.libs/*.so* ${DIR}/build/python/lib

cd ${DIR}/build
wget https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-0.5.2.tar.gz
tar xf libwebp-0.5.2.tar.gz
cd libwebp-0.5.2
./configure #--prefix=$PREFIX
make -j4
make install

cd ${DIR}/build
wget https://download.osgeo.org/libtiff/tiff-4.2.0.tar.gz
tar xf tiff-4.2.0.tar.gz
cd tiff-4.2.0
./configure #--prefix=$PREFIX
make -j4
make install

cd ${DIR}/build
wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/2.0.6.tar.gz
tar xf 2.0.6.tar.gz
cd libjpeg-turbo-2.0.6
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j4
make install
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DWITH_JPEG8=1
make -j4
make install

#mv ${DIR}/build/python /snap/home-assistant/current
cd $PREFIX
python -m venv home-assistant
export LD_LIBRARY_PATH=$PREFIX/python/lib
sed -i 's/include-system-site-packages = false/include-system-site-packages = true/g' home-assistant/pyvenv.cfg
source home-assistant/bin/activate
mv /core-src ${DIR}/build
cd ${DIR}/build/core-src
pip install wheel Cython --constraint homeassistant/package_constraints.txt
pip install --no-cache-dir --no-index --only-binary=:all: --find-links ${WHEELS_LINKS} -r requirements_all.txt --constraint homeassistant/package_constraints.txt
pip install .
cd $PREFIX
python -c "import homeassistant"
python -c "import asyncio"
#mv /snap/home-assistant/current/python ${DIR}/build

#cp /lib/ld-musl-*.so* ${DIR}/build/python/lib
#ARCH=$(uname -m)
#if [[ $ARCH == "armv7l" ]]; then
#    ARCH=armhf
#fi
#cp /lib/*-linux-musl*/libc.so ${DIR}/build/python/lib/libc.musl-$ARCH.so.1

#find ${DIR}/build -name "*musl"'
#sed -i 's|VIRTUAL_ENV=.*|VIRTUAL_ENV=/snap/home-assistant/current/home-assistant|g' ${DIR}/build/home-assistant/bin/activate
find $PREFIX -type f -executable -exec sed -i 's|#!.*/bin/python.*|#!'$PREFIX'/python/bin/python|g' {} \;
sed -i 's|home.*|home = '$PREFIX'/python/bin|g' $PREFIX/pyvenv.cfg
#rm ${DIR}/build/home-assistant/bin/python3
#ln -s /snap/home-assistant/current/python/bin/python ${DIR}/build/home-assistant/bin/python3
rm -rf ${DIR}/build
mv $PREFIX/* /
