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

set -xe
TIMESTAMP=$(date +"%Y%m%d%H%M")
echo "logging to /var/log/yaml_builds/1prom-gen_$TIMESTAMP.log"
mkdir -p /var/log/yaml_builds
exec > /var/log/yaml_builds/1prom-gen_$TIMESTAMP.log
exec 2>&1

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

create_directories() {
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
   rm -f ./tars/promenade-bundle-$SITE.tar
   tar cvf ./tars/promenade-bundle-$SITE.tar -C ./tars/$SITE .
}

create_directories
get_site_config
gen_certs
gen_bundle
create_scripts
prepare_tar
