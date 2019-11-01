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

set -x

source $(dirname $0)/setenv.sh

if [ -z "$1" ]
then
  echo "Please pass site name as command line argument"
  exit -2
else
  SITE=${SITE:-$1}
  echo "SITE=$SITE"
fi

cd $YAML_BUILDS

# ECHO INPUT FILE TO LOGS FOR TROUBLESHOOTING
echo "#######################################"
echo "# USING INPUT FILE [${YAML_BUILDS}/${SITE}.yaml]"
echo "#######################################"
sed -E 's/(^.*password:).*/\1 ###PASSWORD REMOVED####/g' ${YAML_BUILDS}/${SITE}.yaml
echo "#######################################"

echo "# NOTE: root ssh key will be used for genesis_ssh_public_key if no key in yaml"
RCKEY=$(cat ~/.ssh/id_rsa.pub | sed -e 's/[\/&]/\\&/g')
sed -i -e "s/genesis_ssh_public_key\:\s*$/genesis_ssh_public_key: \'$RCKEY\'/" $SITE.yaml

python ./scripts/jcopy.py $SITE.yaml ./tools/j2/set_site_env.sh ./tools/env_$SITE.sh
source ./tools/env_$SITE.sh

if [ ! -d "$AIRSHIP_TREASUREMAP" ] && [ -f "${AIRSHIP_TREASUREMAP}.tgz" ]; then
  echo "Expanding [${AIRSHIP_TREASUREMAP}.tgz] to directory [$AIRSHIP_TREASUREMAP]."
  mkdir -p "$AIRSHIP_TREASUREMAP"
  tar xzvf "${AIRSHIP_TREASUREMAP}.tgz" --strip-components=1 -C "$AIRSHIP_TREASUREMAP"
fi

if [ ! -d "$AIRSHIP_TREASUREMAP" ]; then
  echo "ERROR: Missing AIRSHIP_TREASUREMAP directory [$AIRSHIP_TREASUREMAP]."
  exit -1
fi

if [ ! -d "$AIRSHIP_TEMPLATES" ]; then
  echo "ERROR: Missing AIRSHIP_TEMPLATES directory [$AIRSHIP_TEMPLATES]."
  exit -1
fi

echo "# Generating templates to $YAML_BUILDS/site/$SITE"
rm -rf $YAML_BUILDS/site/$SITE
mkdir -p $YAML_BUILDS/site/$SITE
python ./scripts/jcopy.py $SITE.yaml $AIRSHIP_TEMPLATES $YAML_BUILDS/site/$SITE

echo "# Merging config files to $AIRSHIP_TREASUREMAP/site/$SITE"
rm -rf $AIRSHIP_TREASUREMAP/site/$SITE
mkdir -p $AIRSHIP_TREASUREMAP/site/$SITE

cp -r $AIRSHIP_TREASUREMAP/site/seaworthy/* $AIRSHIP_TREASUREMAP/site/$SITE
cp -r $YAML_BUILDS/site/$SITE/* $AIRSHIP_TREASUREMAP/site/$SITE

CONFIG_COUNT=`find $AIRSHIP_TREASUREMAP/site/$SITE -type f | wc -l`
echo "#######################################"
echo "# Created site $AIRSHIP_TREASUREMAP/site/$SITE with $CONFIG_COUNT config files"
echo "#######################################"

# UNCOMMENT TO DEBUG/LINT GENERATED YAML FILES
#(
#echo "# Linting config files in $AIRSHIP_TREASUREMAP/site/$SITE"
#cd $AIRSHIP_TREASUREMAP
#$AIRSHIP_TREASUREMAP/tools/airship pegleg site -r /target lint $SITE -x P001 -x P005 || true
#)

echo "#######################################"
echo "# $0 finished"
echo "#######################################"
