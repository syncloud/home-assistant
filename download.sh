#!/bin/bash -xe

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd ${DIR}/build

${DIR}/apt.sh wget unzip

${DIR}/download-retry.sh https://github.com/efficiosoft/ldap-auth-sh/archive/refs/heads/master.tar.gz master.tar.gz
tar xf master.tar.gz
mv ldap-auth-sh-master snap/ldap-auth-sh

${DIR}/download-retry.sh https://github.com/hacs/integration/releases/latest/download/hacs.zip hacs.zip
mkdir -p snap/custom_components/hacs
unzip hacs.zip -d snap/custom_components/hacs
