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

# ECHO INPUT FILE TO LOGS FOR TROUBLESHOOTING
echo "#######################################"
echo "# USING INPUT FILE [$SITE.yaml]"
echo "#######################################"
cat $SITE.yaml
echo "#######################################"

cd $YAML_BUILDS
python ./scripts/jcopy.py $SITE.yaml ./tools/j2/set_site_env.sh ./tools/env_$SITE.sh
source ./tools/env_$SITE.sh

if [ ! -d "$AIRSHIP_TREASUREMAP" ]; then
  echo "ERROR: Missing AIRSHIP_TREASUREMAP directory [$AIRSHIP_TREASUREMAP]."
  exit -1
fi

if [ ! -d "$AIRSHIP_TEMPLATES" ]; then
  echo "ERROR: Missing AIRSHIP_TEMPLATES directory [$AIRSHIP_TEMPLATES]."
  exit -1
fi

python ./scripts/jcopy.py $SITE.yaml $AIRSHIP_TEMPLATES $YAML_BUILDS/site/$SITE
cp -r site/common/* site/$SITE/
