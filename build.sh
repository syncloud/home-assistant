#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#VERSION=2021.3.4
mkdir -p ${DIR}/build/bin

${DIR}/build/python/bin/pip install -r ${DIR}/requirements.txt
#sed -i 's/boto3==.*/boto3==1.10.0/g' ${DIR}/build/home-assistant/requirements_all.txt
#sed -i 's/hangups==.*/hangups==0.4.13 /g' ${DIR}/build/home-assistant/requirements_all.txt
#sed -i 's/websocket-client==.*/websocket-client==0.57.0 /g' ${DIR}/build/home-assistant/requirements_all.txt
#sed -i '/eebrightbox==.*/d' ${DIR}/build/home-assistant/requirements_all.txt
#sed -i '/ibm-watson==.*/d' ${DIR}/build/home-assistant/requirements_all.txt
#sed -i '/meteofrance-api==.*/d' ${DIR}/build/home-assistant/requirements_all.txt
#sed -i '/mitemp_bt==.*/d' ${DIR}/build/home-assistant/requirements_all.txt
#sed -i '/mycroftapi==.*/d' ${DIR}/build/home-assistant/requirements_all.txt

#${DIR}/build/python/bin/pip install -r ${DIR}/build/home-assistant/requirements.txt

#${DIR}/build/python/bin/python ${DIR}/build/home-assistant/setup.py install

#${DIR}/build/python/bin/pip install homeassistant==${VERSION}

#${DIR}/build/python/bin/python  ${DIR}/build/python/bin/hass
cd ${DIR}/build
${DIR}/build/python/bin/python -m venv venv
export LD_LIBRARY_PATH=${DIR}/build/python/lib
source venv/bin/activate
cd ${DIR}/build/home-assistant
pip install wheel Cython --constraint homeassistant/package_constraints.txt
pip install -r requirements_all.txt --constraint homeassistant/package_constraints.txt
python setup.py install
