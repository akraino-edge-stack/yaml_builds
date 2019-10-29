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

{% if 'site_type' in yaml %}
export SITE_TYPE={{yaml.site_type}}
echo SITE_TYPE=$SITE_TYPE
export AIRSHIP_TREASUREMAP=/opt/akraino/yaml_builds/site_type/{{yaml.site_type}}/treasuremap
echo AIRSHIP_TREASUREMAP=$AIRSHIP_TREASUREMAP
export AIRSHIP_TEMPLATES=/opt/akraino/yaml_builds/site_type/{{yaml.site_type}}/templates/
echo AIRSHIP_TEMPLATES=$AIRSHIP_TEMPLATES
{% endif %}
export GENESIS_HOST={{yaml.genesis.host}}
echo GENESIS_HOST=$GENESIS_HOST
export PXE_INTERFACE={{yaml.networks.pxe.interface}}
echo PXE_INTERFACE=$PXE_INTERFACE
export HOST_INTERFACE={{yaml.networks.host.interface}}
echo HOST_INTERFACE=$HOST_INTERFACE
export GENESIS_NAME={{yaml.genesis.name}}
echo GENESIS_NAME=$GENESIS_NAME
