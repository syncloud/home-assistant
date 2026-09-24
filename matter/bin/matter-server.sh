#!/bin/bash -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

LIBS=$(echo ${DIR}/lib/*-linux-gnu*)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/*-linux-gnu*)
LIBS=$LIBS:${DIR}/usr/local/lib

export PYTHONPATH=${DIR}/usr/local/lib/python3.12/site-packages
export PATH=${DIR}/usr/local/bin:$PATH
export SSL_CERT_FILE=${DIR}/etc/ssl/certs/ca-certificates.crt
export REQUESTS_CA_BUNDLE=${SSL_CERT_FILE}

exec ${DIR}/lib/*-linux-gnu*/ld-linux-*.so.* --library-path $LIBS \
  ${DIR}/usr/local/bin/python3.12 ${DIR}/usr/local/bin/matter-server "$@"
