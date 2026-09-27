#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT=$( cd "${DIR}/.." && pwd )
cd ${ROOT}

SITE_PACKAGES=$(echo build/snap/home-assistant/usr/local/lib/python3.*/site-packages)
CORE=build/snap/home-assistant/usr/src/homeassistant

git apply --directory="${SITE_PACKAGES}" patches/matter-client-unix-socket.patch
git apply --directory="${SITE_PACKAGES}" patches/otbr-client-unix-socket.patch
git apply --directory="${CORE}" patches/matter-default-url.patch
git apply --directory="${CORE}" patches/otbr-default-url.patch
git apply --directory="${CORE}" patches/system-config.patch
