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

import os
import sys
import yaml
import jinja2
import subprocess

with open(sys.argv[1]) as f:
  yaml = yaml.safe_load(f)

def create_rc_genesis(source, target_suffix):
  env = jinja2.Environment()
  env.trim_blocks = True
  env.lstrip_blocks = True
  
  with open(source) as fd:
    template = env.from_string(fd.read())
  data = template.render(yaml=yaml)
  target_file = yaml['genesis']['name']+target_suffix
  fd2 = open(target_file,'w')
  fd2.write(data)
  fd2.write("\n")
  fd2.close()
  print '{0} -> {1}'.format(source, target_file)

def create_rc_masters(source, target_suffix):
  env = jinja2.Environment()
  env.trim_blocks = True
  env.lstrip_blocks = True

  for master in yaml['masters'] and type(yaml['masters']) is list:
    with open(source) as fd:
      template = env.from_string(fd.read())
    data = template.render(yaml=master)
    target_file = "server-config/"+master['name']+target_suffix
    print target_file
    if os.path.exists(target_file):
      print 'rc file exists maynot be new node'
      continue
    if not os.path.exists(os.path.dirname(target_file)):
      os.makedirs(os.path.dirname(target_file))
    fd2 = open(target_file,'w')
    fd2.write(data)
    fd2.write("\n")
    fd2.close()
    print '{0} -> {1}'.format(source, target_file)
    command = '/opt/akraino/tools/apply_dellxml.sh --rc {0} --template dell_r740_g14_uefi_base.xml.template --no-confirm'.format(target_file)
    print 'command: {0}'.format(command)
    os.system(command)

def create_rc_workers(source, target_suffix):
  env = jinja2.Environment()
  env.trim_blocks = True
  env.lstrip_blocks = True

  if 'workers' in yaml and type(yaml['workers']) is list:
    for master in yaml['workers']:
      with open(source) as fd:
        template = env.from_string(fd.read())
      data = template.render(yaml=master)
      target_file = "server-config/"+master['name']+target_suffix
      print target_file
      if os.path.exists(target_file):
        print 'rc file exists maynot be new node'
        continue
      if not os.path.exists(os.path.dirname(target_file)):
        os.makedirs(os.path.dirname(target_file))
      fd2 = open(target_file,'w')
      fd2.write(data)
      fd2.write("\n")
      fd2.close()
      print '{0} -> {1}'.format(source, target_file)
      command = '/opt/akraino/tools/apply_dellxml.sh --rc {0} --template dell_r740_g14_uefi_base.xml.template --no-confirm'.format(target_file)
      print 'command: {0}'.format(command)
      os.system(command)

if len(sys.argv) != 2:
  print 'usage: update_bios_settings.py <yaml>'
  sys.exit(1)

#create_rc_genesis("tools/j2/serverrc.j2", "rc")
create_rc_masters("tools/j2/serverrc_raid.j2", "rc.raid")
create_rc_workers("tools/j2/serverrc_raid.j2", "rc.raid")

