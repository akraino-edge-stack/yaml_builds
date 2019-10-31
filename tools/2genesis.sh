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

if [ -z "$YAML_BUILDS" ]
then
  echo "Please set YAML_BUILDS"
  exit -3
fi


source $(dirname $0)/env_$SITE.sh

cd $YAML_BUILDS
# Install OS on Genesis
python $YAML_BUILDS/scripts/jcopy.py $SITE.yaml $YAML_BUILDS/tools/j2/serverrc.j2 $YAML_BUILDS/tools/"$GENESIS_NAME"rc
/opt/akraino/redfish/install_server_os.sh --rc /opt/akraino/yaml_builds/tools/"$GENESIS_NAME"rc --skip-confirm

# Stage Airship files on Genesis
scp $YAML_BUILDS/tars/promenade-bundle-$SITE.tar $GENESIS_HOST:/tmp/
ssh $GENESIS_HOST << EOF
  # TODO avoid following hard coding$
  route add -net 192.168.41.0/24 gw 192.168.2.1 bond0.41
  mkdir -p /root/akraino/configs/promenade-bundle
  mv /tmp/promenade-bundle-$SITE.tar /root/akraino/
  cd /root/akraino/
  tar -xmf promenade-bundle-$SITE.tar
  ln -s genesis.sh /root/akraino/configs/promenade-bundle/genesis.sh
EOF

# Update BIOS settings on master and worker nodes
#python $YAML_BUILDS/scripts/update_bios_settings.py $SITE.yaml

echo "#######################################"
echo "# $0 finished"
echo "#######################################"

exec 2>&-
exec 1>&-
exit 0

