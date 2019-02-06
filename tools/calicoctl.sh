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


export ETCD_ENDPOINTS=https://10.96.232.136:6666
if [ -e /etc/calico/pki/key ]; then export ETCD_KEY_FILE=/etc/calico/pki/key; fi;
if [ -e /etc/calico/pki/crt ]; then export ETCD_CERT_FILE=/etc/calico/pki/crt; fi;
if [ -e /etc/calico/pki/ca ]; then export ETCD_CA_CERT_FILE=/etc/calico/pki/ca; fi;
exec /opt/cni/bin/calicoctl.bin $*
