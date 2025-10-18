#!/bin/bash -xe

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd ${DIR}/build

apt update
apt -y install wget unzip

wget https://github.com/efficiosoft/ldap-auth-sh/archive/refs/heads/master.tar.gz
tar xf master.tar.gz
mv ldap-auth-sh-master snap/ldap-auth-sh

wget https://github.com/hacs/integration/releases/latest/download/hacs.zip
mkdir snap/custom_components/hacs
unzip hacs.zip -d snap/custom_components/hacs