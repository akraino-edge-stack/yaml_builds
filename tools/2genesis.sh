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

scp $AIC_CLCP_MANIFESTS/tools/promenade-bundle.tar $GENESIS_HOST:/tmp/
ssh $GENESIS_HOST << EOF
  mkdir -p /opt/sitename/aic-clcp-manifests/tools
  cp /tmp/promenade-bundle.tar /opt/sitename/aic-clcp-manifests/tools/
  cd /opt/sitename/aic-clcp-manifests/tools/
  tar -xmf promenade-bundle.tar
  mkdir configs/promenade
  cp configs/promenade-bundle/*.yaml configs/promenade/
  bash /opt/sitename/aic-clcp-manifests/tools/configs/promenade-bundle/genesis.sh
EOF

