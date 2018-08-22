#!/bin/bash
##############################################################################
# Copyright (c) 2018 AT&T Intellectual Property. All rights reserved.        #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License.                   #
#                                                                            #
# You may obtain a copy of the License at                                    #
#       http://www.apache.org/licenses/LICENSE-2.0                           #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT  #
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.           #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
##############################################################################


# re-generate prom config

set -x

source $(dirname $0)/setenv.sh

PROMENADE_IMAGE=quay.io/airshipit/promenade:009f3de7ecf6afcdd2783ac7a12470394d7dfab3

if [ -z "$AIRSHIP_TREASUREMAP" ]
then
  echo "Please use https://git.openstack.org/openstack/airship-treasuremap to clone airship_treasuremap. Also set AIRSHIP_TREASUREMAP to it."
  exit -1
fi

if [ -z "$1" ]
then
  echo "Please pass site name as command line argument"
  exit -2
else
  SITE=${SITE:-$1}
  echo "SITE=$SITE"
fi
source $(dirname $0)/env_$SITE.sh


# Check that we are root
if [[ $(whoami) != "root" ]]
then
  echo "Must be root to run $0"
  exit -1
fi

if [ -z "$YAML_BUILDS" ]
then
  echo "Please set YAML_BUILDS"
  exit -3
else
  export WORKSPACE=$YAML_BUILDS
  echo "WORKSPACE=$WORKSPACE"
  cd $YAML_BUILDS
fi

install_docker() {
   # Configure proxy for Docker daemon
   mkdir -p /etc/systemd/system/docker.service.d
   mkdir -p /etc/docker

cat <<EOF > /etc/apt/sources.list.d/promenade-sources.list
deb http://apt.dockerproject.org/repo ubuntu-xenial main
EOF

#cat<<EOF > /etc/docker/daemon.json
#{
#  "insecure-registries": [
#    "artifacts-aic.atlantafoundry.com"
#  ],
#  "live-restore": true,
#  "storage-driver": "overlay2"
#}
#EOF

cat<<EOF > /etc/docker/daemon.json
{
  "live-restore": true,
  "storage-driver": "overlay2"
}
EOF

#Set HTTPS Proxy Variable
cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://one.proxy.att.com:8888"
EOF

#Set HTTPS Proxy Variable
cat <<EOF > /etc/systemd/system/docker.service.d/https-proxy.conf
[Service]
Environment="HTTPS_PROXY=http://one.proxy.att.com:8888"
EOF

apt-key add - <<"ENDKEY"
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBFWln24BEADrBl5p99uKh8+rpvqJ48u4eTtjeXAWbslJotmC/CakbNSqOb9o
ddfzRvGVeJVERt/Q/mlvEqgnyTQy+e6oEYN2Y2kqXceUhXagThnqCoxcEJ3+KM4R
mYdoe/BJ/J/6rHOjq7Omk24z2qB3RU1uAv57iY5VGw5p45uZB4C4pNNsBJXoCvPn
TGAs/7IrekFZDDgVraPx/hdiwopQ8NltSfZCyu/jPpWFK28TR8yfVlzYFwibj5WK
dHM7ZTqlA1tHIG+agyPf3Rae0jPMsHR6q+arXVwMccyOi+ULU0z8mHUJ3iEMIrpT
X+80KaN/ZjibfsBOCjcfiJSB/acn4nxQQgNZigna32velafhQivsNREFeJpzENiG
HOoyC6qVeOgKrRiKxzymj0FIMLru/iFF5pSWcBQB7PYlt8J0G80lAcPr6VCiN+4c
NKv03SdvA69dCOj79PuO9IIvQsJXsSq96HB+TeEmmL+xSdpGtGdCJHHM1fDeCqkZ
hT+RtBGQL2SEdWjxbF43oQopocT8cHvyX6Zaltn0svoGs+wX3Z/H6/8P5anog43U
65c0A+64Jj00rNDr8j31izhtQMRo892kGeQAaaxg4Pz6HnS7hRC+cOMHUU4HA7iM
zHrouAdYeTZeZEQOA7SxtCME9ZnGwe2grxPXh/U/80WJGkzLFNcTKdv+rwARAQAB
tDdEb2NrZXIgUmVsZWFzZSBUb29sIChyZWxlYXNlZG9ja2VyKSA8ZG9ja2VyQGRv
Y2tlci5jb20+iQI4BBMBAgAiBQJVpZ9uAhsvBgsJCAcDAgYVCAIJCgsEFgIDAQIe
AQIXgAAKCRD3YiFXLFJgnbRfEAC9Uai7Rv20QIDlDogRzd+Vebg4ahyoUdj0CH+n
Ak40RIoq6G26u1e+sdgjpCa8jF6vrx+smpgd1HeJdmpahUX0XN3X9f9qU9oj9A4I
1WDalRWJh+tP5WNv2ySy6AwcP9QnjuBMRTnTK27pk1sEMg9oJHK5p+ts8hlSC4Sl
uyMKH5NMVy9c+A9yqq9NF6M6d6/ehKfBFFLG9BX+XLBATvf1ZemGVHQusCQebTGv
0C0V9yqtdPdRWVIEhHxyNHATaVYOafTj/EF0lDxLl6zDT6trRV5n9F1VCEh4Aal8
L5MxVPcIZVO7NHT2EkQgn8CvWjV3oKl2GopZF8V4XdJRl90U/WDv/6cmfI08GkzD
YBHhS8ULWRFwGKobsSTyIvnbk4NtKdnTGyTJCQ8+6i52s+C54PiNgfj2ieNn6oOR
7d+bNCcG1CdOYY+ZXVOcsjl73UYvtJrO0Rl/NpYERkZ5d/tzw4jZ6FCXgggA/Zxc
jk6Y1ZvIm8Mt8wLRFH9Nww+FVsCtaCXJLP8DlJLASMD9rl5QS9Ku3u7ZNrr5HWXP
HXITX660jglyshch6CWeiUATqjIAzkEQom/kEnOrvJAtkypRJ59vYQOedZ1sFVEL
MXg2UCkD/FwojfnVtjzYaTCeGwFQeqzHmM241iuOmBYPeyTY5veF49aBJA1gEJOQ
TvBR8Q==
=Fm3p
-----END PGP PUBLIC KEY BLOCK-----
ENDKEY

   apt-get update
   apt-get install -y docker-engine=1.13.1-0~ubuntu-xenial socat=1.7.3.1-1
   systemctl daemon-reload
   systemctl restart docker || true
}

cleanup() {
   rm -rf ./tars/$SITE/configs/promenade
   rm -rf ./tars/$SITE/configs/promenade-bundle
   mkdir -p ./tars/$SITE/configs/promenade
   mkdir -p ./tars/$SITE/configs/promenade-bundle
}

get_site_config(){
   $YAML_BUILDS/tools/pegleg.sh site -p /site -a /global collect ${SITE} -s /site/tars/$SITE/configs/promenade
}

gen_certs() {
   docker run --env http_proxy=$http_proxy  --env https_proxy=$https_proxy --user 0 --rm -t -w /target -v $(pwd):/target ${PROMENADE_IMAGE} promenade generate-certs -o /target/tars/$SITE/configs/promenade /target/tars/$SITE/configs/promenade/*.yaml
}

gen_bundle(){
   docker run --env http_proxy=$http_proxy  --env https_proxy=$https_proxy --user 0 --rm -t -w /target -v $(pwd):/target ${PROMENADE_IMAGE} promenade build-all --validators -o /target/tars/$SITE/configs/promenade-bundle /target/tars/$SITE/configs/promenade/*.yaml
}

create_scripts() {
  KEYSTONE_IMAGE=$(grep "keystone_db_sync: docker.io" $AIRSHIP_TREASUREMAP/global/v4.0/software/config/versions.yaml | uniq | awk '{print $2}')
  SHIPYARD_IMAGE=$(grep "shipyard_db_sync" $AIRSHIP_TREASUREMAP/global/v4.0/software/config/versions.yaml | uniq | awk '{print $2}')

  DRYDOCK_PASSWORD=$(grep "^data:" $YAML_BUILDS/site/$SITE/secrets/passphrases/ucp_drydock_keystone_password.yaml | awk '{print $2}')
  SHIPYARD_PASSWORD=$(grep "^data:" $YAML_BUILDS/site/$SITE/secrets/passphrases/ucp_shipyard_keystone_password.yaml | awk '{print $2}')
  REGION_NAME=$SITE

  cp $YAML_BUILDS/tools/deploy_site.sh $YAML_BUILDS/tars/$SITE/
  sed -i -e "s,KEYSTONE_IMAGE=,KEYSTONE_IMAGE=$KEYSTONE_IMAGE,g" $YAML_BUILDS/tars/$SITE/deploy_site.sh
  sed -i -e "s,SHIPYARD_IMAGE=,SHIPYARD_IMAGE=$SHIPYARD_IMAGE,g" $YAML_BUILDS/tars/$SITE/deploy_site.sh
  sed -i -e "s/DRYDOCK_PASSWORD=/DRYDOCK_PASSWORD=$DRYDOCK_PASSWORD/g" $YAML_BUILDS/tars/$SITE/deploy_site.sh
  sed -i -e "s/SHIPYARD_PASSWORD=/SHIPYARD_PASSWORD=$SHIPYARD_PASSWORD/g" $YAML_BUILDS/tars/$SITE/deploy_site.sh
  sed -i -e "s/REGION_NAME=/REGION_NAME=$REGION_NAME/g" $YAML_BUILDS/tars/$SITE/deploy_site.sh
  sed -i -e "s/{{yaml.genesis.host}}/$GENESIS_HOST/g" $YAML_BUILDS/tars/$SITE/deploy_site.sh

  cp $YAML_BUILDS/tools/update_iptables.sh $YAML_BUILDS/tars/$SITE/
  sed -i -e "s,HOST_INTERFACE=,HOST_INTERFACE=$HOST_INTERFACE,g" $YAML_BUILDS/tars/$SITE/update_iptables.sh
  sed -i -e "s,PXE_INTERFACE=,PXE_INTERFACE=$PXE_INTERFACE,g" $YAML_BUILDS/tars/$SITE/update_iptables.sh

  cp $YAML_BUILDS/tools/cleanup.sh $YAML_BUILDS/tars/$SITE/
}

prepare_tar(){
   rm ./tars/promenade-bundle-$SITE.tar
   tar cvf ./tars/promenade-bundle-$SITE.tar -C ./tars/$SITE .
}

#install_docker
cleanup
get_site_config
gen_certs
gen_bundle
create_scripts
prepare_tar
