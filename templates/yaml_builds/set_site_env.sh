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


export GENESIS_HOST={{yaml.genesis.host}}
echo GENESIS_HOST=$GENESIS_HOST
export GENESIS_PXE={{yaml.genesis.pxe}}
echo GENESIS_PXE=$GENESIS_PXE
export REGIONAL_SERVER_IP={{yaml.regional_server.ip}}
echo REGIONAL_SERVER_IP=$REGIONAL_SERVER_IP
