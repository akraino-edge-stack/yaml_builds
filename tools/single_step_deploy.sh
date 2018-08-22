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

if [ -z "$1" ]
then
  echo "Plese pass site name as command line argument"
  exit -2
else
  export SITE=${SITE:-$1}
  echo "SITE=$SITE"
fi

source $(dirname $0)/setenv.sh
TIMESTAMP=$(date +"%Y%m%d%H%M")
echo "TIMESTAMP=$TIMESTAMP"

echo "Validating the setup and generating the tar file"
bash $YAML_BUILDS/tools/1prom-gen.sh $SITE > /var/log/yaml_builds/1prom-gen-$TIMESTAMP.log 2>&1
if [ $? -ne 0 ]
then
  echo "Error:Could not generate tar file. So stopping here"
  exit 1 
fi

echo "Bringing up the genesis node"
bash $YAML_BUILDS/tools/2genesis.sh $SITE > /var/log/yaml_builds/2genesis-$TIMESTAMP.log 2>&1
if [ $? -ne 0 ]
then
  echo "Error:Could not bringup the genesis nodes. So stopping here"
  exit 2
fi

date
sleep 900;

echo "Deploying the site"
bash $YAML_BUILDS/tools/3deploy_site.sh $SITE > /var/log/yaml_builds/3deploy-$TIMESTAMP.log 2>&1
if [ $? -ne 0 ]
then
  echo "Error:Could not deploy the site."
  exit 3
fi
echo "We are done."
