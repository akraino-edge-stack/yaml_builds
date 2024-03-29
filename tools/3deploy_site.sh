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


set -xe
LOGDIR="/var/log/akraino"
mkdir -p $LOGDIR
LOGFILE="$LOGDIR/${1}_$(date +"%Y%m%d%H%M%z")_$(basename $0|cut -d. -f1)"
echo "logging to $LOGFILE"
exec 1> >(tee -a $LOGFILE)
exec 2>&1

source $(dirname $0)/setenv.sh

if [ -z "$1" ]
then
  echo "Please pass site name as command line argument"
  exit -2
else
  SITE=${SITE:-$1}
  echo "SITE=$SITE"
fi

source $(dirname $0)/env_$SITE.sh

ssh $GENESIS_HOST << EOF
  cd /root/akraino
  echo "#######################################################"
  echo "# Running genesis.sh script "
  echo "#######################################################"
  bash ./configs/promenade-bundle/genesis.sh
  # Shipyard takes time to really come up and start responding.
  date
  sleep 900
  # Following is a workaround, tested on dell servers.
  # TODO to be removed when not required.
  echo "#######################################################"
  echo "# Updating iptables "
  echo "#######################################################"
  bash update_iptables.sh
  echo "#######################################################"
  echo "# Running deploy_site.sh script "
  echo "#######################################################"
  bash deploy_site.sh
EOF

exec 2>&-
exec 1>&-
exit 0

