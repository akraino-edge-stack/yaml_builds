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
LOGDIR="/var/log/akraino"
mkdir -p $LOGDIR
LOGFILE="$LOGDIR/${1}_$(date +"%Y%m%d%H%M%z")_$(basename $0|cut -d. -f1)"
echo "logging to $LOGFILE"
exec 1> >(tee -a $LOGFILE)
exec 2>&1

source $(dirname $0)/setenv.sh

PROMENADE_IMAGE=quay.io/airshipit/promenade:009f3de7ecf6afcdd2783ac7a12470394d7dfab3

if [ -z "$1" ]
then
  echo "Please pass site name as command line argument"
  exit -2
else
  SITE=${SITE:-$1}
  echo "SITE=$SITE"
fi
source $(dirname $0)/env_$SITE.sh

if [ ! -d "$AIRSHIP_TREASUREMAP" ]; then
  echo "ERROR: Missing AIRSHIP_TREASUREMAP directory [$AIRSHIP_TREASUREMAP]."
  exit -1
fi

if [ ! -d "$AIRSHIP_TEMPLATES" ]; then
  echo "ERROR: Missing AIRSHIP_TEMPLATES directory [$AIRSHIP_TEMPLATES]."
  exit -1
fi

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

(
echo "# Collecting config files in $AIRSHIP_TREASUREMAP/site/$SITE"
cd $AIRSHIP_TREASUREMAP
rm -rf $AIRSHIP_TREASUREMAP/${SITE}_collected
mkdir -p  $AIRSHIP_TREASUREMAP/${SITE}_collected
$AIRSHIP_TREASUREMAP/tools/airship pegleg site -r /target collect $SITE -s ${SITE}_collected || true
)

(
echo "# Rendering config files in $AIRSHIP_TREASUREMAP/site/$SITE"
cd $AIRSHIP_TREASUREMAP
$AIRSHIP_TREASUREMAP/tools/airship pegleg site -r /target render $SITE > ${SITE}_render.yaml || true
)

(
echo "# Generating certs for $AIRSHIP_TREASUREMAP/site/$SITE"
cd $AIRSHIP_TREASUREMAP
rm -rf $AIRSHIP_TREASUREMAP/${SITE}_certs
mkdir -p  $AIRSHIP_TREASUREMAP/${SITE}_certs
$AIRSHIP_TREASUREMAP/tools/airship promenade generate-certs -o /target/${SITE}_certs /target/${SITE}_collected/*.yaml
)

(
echo "# Copying certs to $AIRSHIP_TREASUREMAP/site/$SITE"
cd $AIRSHIP_TREASUREMAP
mkdir -p  $AIRSHIP_TREASUREMAP/site/${SITE}/secrets/certificates
cp $AIRSHIP_TREASUREMAP/${SITE}_certs/certificates.yaml $AIRSHIP_TREASUREMAP/site/${SITE}/secrets/certificates
)

(
echo "# Collecting config files with certs in $AIRSHIP_TREASUREMAP/site/$SITE"
cd $AIRSHIP_TREASUREMAP
rm -rf $AIRSHIP_TREASUREMAP/${SITE}_collected
mkdir -p  $AIRSHIP_TREASUREMAP/${SITE}_collected
$AIRSHIP_TREASUREMAP/tools/airship pegleg site -r /target collect $SITE -s ${SITE}_collected
)

(
echo "# Generating Promenade bundle with $AIRSHIP_TREASUREMAP/${SITE}_collected"
cd $AIRSHIP_TREASUREMAP
rm -rf $AIRSHIP_TREASUREMAP/${SITE}_bundle
mkdir -p  $AIRSHIP_TREASUREMAP/${SITE}_bundle
$AIRSHIP_TREASUREMAP/tools/airship promenade build-all --validators -o /target/${SITE}_bundle /target/${SITE}_collected/*.yaml
)

(
echo "# Copying scripts to $AIRSHIP_TREASUREMAP/${SITE}_bundle"
  SHIPYARD_PASSWORD=$(grep "^data:" $AIRSHIP_TREASUREMAP/site/$SITE/secrets/passphrases/ucp_shipyard_keystone_password.yaml | awk '{print $2}')
  AUTH_DOMAIN=$(grep "ingress_domain:" $AIRSHIP_TREASUREMAP/site/$SITE/networks/common-addresses.yaml | awk '{print $2}')
  AUTH_URL="http:\/\/iam-sw.${AUTH_DOMAIN}:80\/v3"
  REGION_NAME=$SITE

  DEPLOY_SCRIPT=$AIRSHIP_TREASUREMAP/${SITE}_bundle/deploy_site.sh
  IPTABLES_SCRIPT=$AIRSHIP_TREASUREMAP/${SITE}_bundle/update_iptables.sh

  cp $YAML_BUILDS/tools/deploy_site.sh $AIRSHIP_TREASUREMAP/${SITE}_bundle
  sed -i -e "s|OS_AUTH_URL=|OS_AUTH_URL=\"${AUTH_URL}\"|g" $DEPLOY_SCRIPT
  sed -i -e "s/OS_PASSWORD=/OS_PASSWORD=$SHIPYARD_PASSWORD/g" $DEPLOY_SCRIPT
  sed -i -e "s/REGION_NAME=/REGION_NAME=$REGION_NAME/g" $DEPLOY_SCRIPT
  sed -i -e "s/{{yaml.genesis.host}}/$GENESIS_HOST/g" $DEPLOY_SCRIPT

  cp $YAML_BUILDS/tools/update_iptables.sh $AIRSHIP_TREASUREMAP/${SITE}_bundle
  sed -i -e "s,HOST_INTERFACE=,HOST_INTERFACE=$HOST_INTERFACE,g" $IPTABLES_SCRIPT
  sed -i -e "s,PXE_INTERFACE=,PXE_INTERFACE=$PXE_INTERFACE,g" $IPTABLES_SCRIPT

  cp $YAML_BUILDS/tools/cleanup.sh $AIRSHIP_TREASUREMAP/${SITE}_bundle
)

(
    echo "# Generating Promenade tar bundle $YAML_BUILDS/tars/promenade-bundle-$SITE.tar"
    mkdir -p $YAML_BUILDS/tars
    rm -f $YAML_BUILDS/tars/promenade-bundle-$SITE.tar
    tar cvf $YAML_BUILDS/tars/promenade-bundle-$SITE.tar --transform 's,^,configs/promenade-bundle/,' -C $AIRSHIP_TREASUREMAP/${SITE}_bundle .
    tar rvf $YAML_BUILDS/tars/promenade-bundle-$SITE.tar --transform 's,^,configs/promenade/,' -C $AIRSHIP_TREASUREMAP/${SITE}_collected  .
    tar rvf $YAML_BUILDS/tars/promenade-bundle-$SITE.tar -C $AIRSHIP_TREASUREMAP tools global
)

echo "#######################################"
echo "# $0 finished"
echo "#######################################"

pkill -9 $$ && exit 0
