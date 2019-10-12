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

export SITE_TYPE=ovsdpdk
echo SITE_TYPE=$SITE_TYPE
export AIRSHIP_TREASUREMAP=/opt/akraino/yaml_builds/site_type/ovsdpdk/airship-treasuremap
echo AIRSHIP_TREASUREMAP=$AIRSHIP_TREASUREMAP
export AIRSHIP_TEMPLATES=/opt/akraino/yaml_builds/site_type/ovsdpdk/templates/
echo AIRSHIP_TEMPLATES=$AIRSHIP_TEMPLATES
export GENESIS_HOST=10.51.34.233
echo GENESIS_HOST=$GENESIS_HOST
export PXE_INTERFACE=eno3
echo PXE_INTERFACE=$PXE_INTERFACE
export HOST_INTERFACE=bond0.408
echo HOST_INTERFACE=$HOST_INTERFACE
export GENESIS_NAME=aknode23
echo GENESIS_NAME=$GENESIS_NAME
