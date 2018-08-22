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


set -x

# Regional Server specific variables
KEYSTONE_IMAGE=
SHIPYARD_IMAGE=
# Site specific variables
DRYDOCK_PASSWORD=
SHIPYARD_PASSWORD=
REGION_NAME=


clean_configdocs(){
  ## clean site YAMLs from Deckhand
  TOKEN=`sudo docker run --rm --net=host -e OS_AUTH_URL=http://keystone-api.ucp.svc.cluster.local:80/v3 -e OS_PROJECT_DOMAIN_NAME=default -e OS_USER_DOMAIN_NAME=default -e OS_PROJECT_NAME=service -e OS_REGION_NAME=RegionOne -e OS_USERNAME=drydock -e OS_PASSWORD=${DRYDOCK_PASSWORD} -e OS_IDENTITY_API_VERSION=3 ${KEYSTONE_IMAGE} openstack token issue -f value -c id`

  curl -v -X DELETE -H "X-AUTH-TOKEN: $TOKEN" -H 'Content-Type: application/x-yaml' http://deckhand-int.ucp.svc.cluster.local:9000/api/v1.0/revisions
}

create_configdocs(){
  sudo docker run -v $(pwd):/target -e 'OS_AUTH_URL=http://keystone-api.ucp.svc.cluster.local:80/v3' -e OS_PASSWORD=${SHIPYARD_PASSWORD} -e 'OS_PROJECT_DOMAIN_NAME=default' -e 'OS_PROJECT_NAME=service' -e 'OS_USERNAME=shipyard' -e 'OS_USER_DOMAIN_NAME=default' -e 'OS_IDENTITY_API_VERSION=3' --rm --net=host ${SHIPYARD_IMAGE} create configdocs ${REGION_NAME} --directory=/target/configs/promenade

  sleep 5
}

renderedconfigdocs(){
  sudo docker run -v $(pwd):/target -e 'OS_AUTH_URL=http://keystone-api.ucp.svc.cluster.local:80/v3' -e OS_PASSWORD=${SHIPYARD_PASSWORD} -e 'OS_PROJECT_DOMAIN_NAME=default' -e 'OS_PROJECT_NAME=service' -e 'OS_USERNAME=shipyard' -e 'OS_USER_DOMAIN_NAME=default' -e 'OS_IDENTITY_API_VERSION=3' --rm --net=host ${SHIPYARD_IMAGE} get renderedconfigdocs --committed > /tmp/renderedconfigdocs.yaml

  sleep 5
}

commit_configdocs(){
  sudo docker run -v $(pwd):/target -e 'OS_AUTH_URL=http://keystone-api.ucp.svc.cluster.local:80/v3' -e OS_PASSWORD=${SHIPYARD_PASSWORD} -e 'OS_PROJECT_DOMAIN_NAME=default' -e 'OS_PROJECT_NAME=service' -e 'OS_USERNAME=shipyard' -e 'OS_USER_DOMAIN_NAME=default' -e 'OS_IDENTITY_API_VERSION=3' --rm --net=host ${SHIPYARD_IMAGE} commit configdocs

  sleep 5
}

deploy_site(){
  sudo docker run -e 'OS_AUTH_URL=http://keystone-api.ucp.svc.cluster.local:80/v3' -e OS_PASSWORD=${SHIPYARD_PASSWORD} -e 'OS_PROJECT_DOMAIN_NAME=default' -e 'OS_PROJECT_NAME=service' -e 'OS_USERNAME=shipyard' -e 'OS_USER_DOMAIN_NAME=default' -e 'OS_IDENTITY_API_VERSION=3' --rm --net=host ${SHIPYARD_IMAGE} create action deploy_site
}

update_site(){
  sudo docker run -e 'OS_AUTH_URL=http://keystone-api.ucp.svc.cluster.local:80/v3' -e OS_PASSWORD=${SHIPYARD_PASSWORD} -e 'OS_PROJECT_DOMAIN_NAME=default' -e 'OS_PROJECT_NAME=service' -e 'OS_USERNAME=shipyard' -e 'OS_USER_DOMAIN_NAME=default' -e 'OS_IDENTITY_API_VERSION=3' --rm --net=host ${SHIPYARD_IMAGE} create action update_site
}


getactions(){
  sudo docker run -v $(pwd):/target -e 'OS_AUTH_URL=http://keystone-api.ucp.svc.cluster.local:80/v3' -e OS_PASSWORD=${SHIPYARD_PASSWORD} -e 'OS_PROJECT_DOMAIN_NAME=default' -e 'OS_PROJECT_NAME=service' -e 'OS_USERNAME=shipyard' -e 'OS_USER_DOMAIN_NAME=default' -e 'OS_IDENTITY_API_VERSION=3' --rm --net=host ${SHIPYARD_IMAGE} get actions

  sleep 5
}

clean_configdocs
create_configdocs
commit_configdocs
renderedconfigdocs

deploy_site
#getactions
#update_site

##
#"Look at.. for progress"
#'MaaS GUI -> http://{{yaml.genesis.host}}:30001/MAAS/#/nodes'
#'Airflow GUI -> http://{{yaml.genesis.host}}:30004/admin/taskinstance/'

