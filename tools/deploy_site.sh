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
TIMESTAMP=$(date +"%Y%m%d%H%M")
LOGFILE=/var/log/deploy_site_$TIMESTAMP.log
echo "logging to $LOGFILE"
exec 1> >(tee -a $LOGFILE)
exec 2>&1

# Site specific variables
export OS_AUTH_URL=
export OS_USERNAME=shipyard
export OS_PASSWORD=
REGION_NAME=
MAAS_URL=
AIRFLOW_URL=

sleep 900

tools/airship shipyard create configdocs ${REGION_NAME} --directory=/target/configs/promenade

tools/airship shipyard commit configdocs

tools/airship shipyard create action deploy_site

tools/airship shipyard get actions

SHIPYARD_ACTION=$(tools/airship shipyard get actions | awk '/deploy_site/ {print $2};')
SHIPYARD_CLI="tools/airship shipyard describe $SHIPYARD_ACTION"

echo "## Airship deployment has been started..."
echo "##"
echo "## To monitor progress check:"
echo "## MaaS GUI    -> $MAAS_URL"
echo "## Shipyard cli-> $SHIPYARD_CLI"
#echo "## Airflow GUI -> $AIRFLOW_URL"

while ( ! $SHIPYARD_CLI | grep -qe '^Lifecycle.*Complete' && ! $SHIPYARD_CLI | grep -qe '^step.*failed'); do
  $SHIPYARD_CLI
  echo "## Sleeping for 10 mins"
  sleep 600
done
$SHIPYARD_CLI

exec 2>&-
exec 1>&-
$SHIPYARD_CLI | grep -qe '^step.*failed'
