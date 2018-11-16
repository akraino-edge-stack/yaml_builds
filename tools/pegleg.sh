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

#!/usr/bin/env bash

set -e

: ${IMAGE:=quay.io/airshipit/pegleg:a3da86e3119d150a4f36fd93657455e6ec0c51ed}

: ${TERM_OPTS:=-it}

echo
echo "== NOTE: Workspace $WORKSPACE is the execution directory in the container =="
echo

# Working directory inside container to execute commands from and mount from
# host OS
container_workspace_path='/workspace'

docker run --rm $TERM_OPTS \
    --net=host \
    --workdir="$container_workspace_path" \
    -v "${HOME}/.ssh:${container_workspace_path}/.ssh" \
    -v "${WORKSPACE}:$container_workspace_path" \
    -e "PEGLEG_PASSPHRASE=$PEGLEG_PASSPHRASE" \
    -e "PEGLEG_SALT=$PEGLEG_SALT" \
    -e "http_proxy=http://one.proxy.att.com:8888/" \
    -e "HTTPS_PROXY=http://one.proxy.att.com:8888/" \
    -e "https_proxy=http://one.proxy.att.com:8888/" \
    -e "HTTP_PROXY=http://one.proxy.att.com:8888/" \
    "${IMAGE}" \
pegleg "${@}"
