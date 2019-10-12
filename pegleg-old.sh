#!/usr/bin/env bash
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

#PEGLEG_IMAGE=${PEGLEG_IMAGE:-quay.io/airshipit/pegleg:09d85465827f1468d3469e5bbcf6b48f25338e7c}
PEGLEG_IMAGE=${PEGLEG_IMAGE:-quay.io/airshipit/pegleg:ac6297eae6c51ab2f13a96978abaaa10cb46e3d6}
#PEGLEG_IMAGE=${PEGLEG_IMAGE:-quay.io/airshipit/pegleg:latest-ubuntu_xenial}

echo
echo "== NOTE: Workspace $WORKSPACE  is available as /workspace in container context =="
echo

docker run --rm -t \
    --net=none \
    --workdir="/site" \
    -v "${WORKSPACE}:/site" \
    -v "${AIRSHIP_TREASUREMAP}:/global" \
    "${PEGLEG_IMAGE}" \
        pegleg "${@}"
