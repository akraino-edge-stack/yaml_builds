#!/bin/bash
##############################################################################
# Copyright (c) 2019 AT&T Intellectual Property. All rights reserved.        #
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
LOGFILE=/var/log/update_software_$TIMESTAMP.log
echo "logging to $LOGFILE"
exec 1> >(tee -a $LOGFILE)
exec 2>&1

# Site specific variables
export OS_AUTH_URL=
export OS_USERNAME=shipyard
export OS_PASSWORD=
REGION_NAME=

tools/airship shipyard create configdocs ${REGION_NAME} --directory=/target/configs/promenade

tools/airship shipyard commit configdocs

SHIPYARD_ACTION=$(tools/airship shipyard create action update_software | awk '/update_software/ {print $2};')

tools/airship shipyard get actions

# Monitor the workflow
tools/airship shipyard describe $SHIPYARD_ACTION

