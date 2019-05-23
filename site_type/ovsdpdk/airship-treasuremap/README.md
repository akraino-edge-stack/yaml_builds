# Akraino Edge Stack
..............................................................................
. Copyright (c) 2019 AT&T Intellectual Property. All rights reserved         .
.                                                                            .
. Licensed under the Apache License, Version 2.0 (the "License"); you may    .
. not use this file except in compliance with the License.                   .
.                                                                            .
. You may obtain a copy of the License at                                    .
.       http://www.apache.org/licenses/LICENSE-2.0                           .
.                                                                            .
. Unless required by applicable law or agreed to in writing, software        .
. distributed under the License is distributed on an "AS IS" BASIS, WITHOUT  .
. WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.           .
. See the License for the specific language governing permissions and        .
. limitations under the License.                                             .
..............................................................................

The files in this directory were created with the following commands:

(
rm -rf airship-treasuremap
git clone https://git.openstack.org/openstack/airship-treasuremap
cd ./airship-treasuremap; 
git checkout 059857148ad142730b5a69374e44a988cac92378; 
rm -rf .git/ .gitreview .zuul.yaml
# SR-IOV UPDATES
sed -i "s/ceph-common=10.2.10/ceph-common=10.2.11/" ./global/v4.0/software/config/versions.yaml
sed -i -e 's|docker.io/openstackhelm/neutron:ocata|docker.io/openstackhelm/neutron:ocata\n      neutron_sriov_agent: \&neutron_sriov docker.io/openstackhelm/neutron:ocata-sriov-1804\n      neutron_sriov_agent_init: \&neutron_sriov_init docker.io/openstackhelm/neutron:ocata-sriov-1804|g' ./global/v4.0/software/config/versions.yaml
sed -i -e 's|neutron_linuxbridge_agent.*|neutron_linuxbridge_agent: *neutron\n        neutron_sriov_agent: *neutron_sriov\n        neutron_sriov_agent_init: *neutron_sriov_init|g' ./global/v4.0/software/config/versions.yaml
)

Akraino Team
