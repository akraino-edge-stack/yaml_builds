# Acraino Edge Stack
..............................................................................
. Copyright © 2018 AT&T Intellectual Property. All rights reserved          .
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


This document explains how to automatically deploy the edge sites from the regional server command line.

This document can be consumed by Camunda developer to expose RESTful APIs that internally invoke commands provided in this document.

### Manual Steps
The goal of the this project is to deploy edge site with no manual interaction but as we are in the process of achieving that, at this point of time we will still need some manual interactions.

All the manual interactions requested are documented here. In future we automate each of the following and this complete section will be removed.
 * python should be installed already
 * jinja2 PyYAML python packages should be available
 * git clone yaml_build project to your favorite location ( say **/opt/**).
~~~
$ git clone http://gerrit.akraino.org/yaml_builds.git
~~~
 * export YAML_BUILDS=<<absolute path of yaml_builds>> created is previous step.
 * aic-clcp-manifests should be installed as explained here https://codecloud.web.att.com/projects/ST_CCP/repos/aic-clcp-manifests/browse/docs/source/deployment_blueprint.md
 * export AIC_CLCP_MANIFESTS
 * As per aic-clcp-manifests documents copy all required files to new <<site_name>>

      This will copy a bunch of .yaml files to $AIC_CLCP_MANIFESTS/sites/<<site_name>>

  * aic-clcp-security-manifests should be installed as explained here https://codecloud.web.att.com/projects/ST_CCP/repos/aic-clcp-manifests/browse/docs/source/deployment_blueprint.md
  * export AIC_CLCP_SECURITY_MANIFESTS
   As per aic-clcp-manifests documents copy all required files to new <<site_name>>

     This will copy a bunch of .yaml files to $AIC_CLCP_MANIFESTS/sites/<<site_name>>

 * Manually verifying the generated .yaml files as explained in 1.1 Manually verifying the .YAMLs
 * Using following commands ssh and scp should be happen from regional servers to genesis host without asking any username/passwords
~~~
ssh-keygen; ssh-copy-id your-host
~~~

 ### 1. Generating YAML files
 To bring up a edge site we need to pass a bunch of configurations as form of .yaml documents. Manually documenting these documents is tedious process so we tried to automate all .yaml files that needs modification.
 ~~~
 $ sh $YAML_BUILDS/tools/generate_yamls.sh <<site_name>>
 ~~~

 Based on the input site name it picks the master input .yaml for that site and generates 23 .yaml files to $AIC_CLCP_MANIFESTS/sites/<<site_name>>

##### 1.1 Manually verifying the .YAMLs
 At the point of writing this document we took effort to automatically generate all the required .yamls but we are just 80% finished on this. So some manual verification required here to validate the generated documents.

### 2. Creating a .tar files
At this step we generate .tar file required to bring up the Genesis node.

~~~
$ sh $YAML_BUILDS/tools/1prom-gen.sh  <<site_name>>
~~~

### 3. Bring up the Genesis node
At this step we transfer the .tar file generated in previous step to genesis node, untars it and executes the genesis.sh available in it.
~~~
$ sh $YAML_BUILDS/tools/2genesis.sh <<site_name>>
~~~
This process takes around 4 hours to complete. Meanwhile use the following command to find out the status. On genesis node it installs kubernetes cluster, UCP (Under Cloud flatform)/Airship and Ceph.
~~~
$ kubectl get pods --all-namespaces
~~~

### 4. Deploy the edge site
At this step it brings other server into the control of Genesis, installs the OS on server using PXE booting, and Required OpenStack components.
~~~
$ sh $YAML_BUILDS/tools/3deploy_site.sh <<site_name>>
~~~

Akraino Team
