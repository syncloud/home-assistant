#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap/python
while ! docker build -t python:syncloud . ; do
  echo "retry docker"
  sleep 1
done
docker build -t python:syncloud .
docker run python:syncloud python --help
docker create --name=python python:syncloud
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
docker export python -o python.tar

tar xf python.tar
rm -rf python.tar
cp ${DIR}/python ${BUILD_DIR}/bin/
ls -la ${BUILD_DIR}/bin
rm -rf ${BUILD_DIR}/usr/src
