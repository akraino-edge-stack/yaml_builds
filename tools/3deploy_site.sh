#!/bin/bash
##############################################################################
# Copyright © 2018 AT&T Intellectual Property. All rights reserved.          #
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


set -x

source $(dirname $0)/setenv.sh

if [ -z "$1" ]
then
  echo "Plese pass site name as command line argument"
  exit -2
else
  SITE=${SITE:-$1}
  echo "SITE=$SITE"
fi

source $(dirname $0)/env_$SITE.sh

KEYSTONE_IMAGE=$(grep "keystone_db_sync" $AIC_CLCP_MANIFESTS/global/v4.0/software/config/versions.yaml | uniq | awk '{print $2}')
SHIPYARD_IMAGE=$(grep "shipyard_db_sync" $AIC_CLCP_MANIFESTS/global/v4.0/software/config/versions.yaml | uniq | awk '{print $2}')

DRYDOCK_PASSWORD=$(grep "^data:" $AIC_CLCP_MANIFESTS/site/$SITE/secrets/passphrases/ucp_drydock_keystone_password.yaml | awk '{print $2}')
SHIPYARD_PASSWORD=$(grep "^data:" $AIC_CLCP_MANIFESTS/site/$SITE/secrets/passphrases/ucp_shipyard_keystone_password.yaml | awk '{print $2}')
REGION_NAME=$SITE

mkdir -p $YAML_BUILDS/tools/$SITE
cp $YAML_BUILDS/tools/deploy_site.sh $YAML_BUILDS/tools/$SITE/
sed -i -e "s,KEYSTONE_IMAGE=,KEYSTONE_IMAGE=$KEYSTONE_IMAGE,g" $YAML_BUILDS/tools/$SITE/deploy_site.sh
sed -i -e "s,SHIPYARD_IMAGE=,SHIPYARD_IMAGE=$SHIPYARD_IMAGE,g" $YAML_BUILDS/tools/$SITE/deploy_site.sh
sed -i -e "s/DRYDOCK_PASSWORD=/DRYDOCK_PASSWORD=$DRYDOCK_PASSWORD/g" $YAML_BUILDS/tools/$SITE/deploy_site.sh
sed -i -e "s/SHIPYARD_PASSWORD=/SHIPYARD_PASSWORD=$SHIPYARD_PASSWORD/g" $YAML_BUILDS/tools/$SITE/deploy_site.sh
sed -i -e "s/REGION_NAME=/REGION_NAME=$REGION_NAME/g" $YAML_BUILDS/tools/$SITE/deploy_site.sh
sed -i -e "s/{{yaml.genesis.host}}/$GENESIS_HOST/g" $YAML_BUILDS/tools/$SITE/deploy_site.sh

scp $YAML_BUILDS/tools/$SITE/deploy_site.sh $GENESIS_HOST:/opt/sitename/aic-clcp-manifests/tools/
ssh $GENESIS_HOST 'bash /opt/sitename/aic-clcp-manifests/tools/deploy_site.sh'
