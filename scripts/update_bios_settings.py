
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

def create_node_rcfile(nodes, defaults, j2template, rcfile_suffix):
  env = jinja2.Environment()
  env.trim_blocks = True
  env.lstrip_blocks = True

  with open(j2template) as fd:
    template = env.from_string(fd.read())

  if type(nodes) is list:
    for node in nodes:
      newnode = dict( defaults.items() + node.items() )
      data = template.render(yaml=newnode)
      rcfile = "server-config/"+newnode['name']+rcfile_suffix
      print rcfile
      if os.path.exists(rcfile):
        print 'warning: rc file {} exists. maynot be new node. overwriting file'.format(rcfile)
        #continue
      if not os.path.exists(os.path.dirname(rcfile)):
        os.makedirs(os.path.dirname(rcfile),0600)
      fd2 = open(rcfile,'w')
      fd2.write(data)
      fd2.write("\n")
      fd2.close()
      print '{0} -> {1}'.format(j2template, rcfile)
      command = ""
      if newnode['vendor'] == "DELL":
        command = '/opt/akraino/redfish/apply_dellxml.sh --rc {0} --template {1} --no-confirm'.format(rcfile, newnode["bios_template"])
      if newnode['vendor'] == "HP" or newnode['vendor'] == "HPE":
        command = '/opt/akraino/redfish/apply_hpejson.sh --rc {0} --template {1} --no-confirm'.format(rcfile, newnode["bios_template"])
      if command:
        p=subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True, preexec_fn=os.setsid)
        print 'process: {}  command: {}'.format(p.pid, command)
        plist.append(p)

### MAIN ###
if len(sys.argv) != 2:
  print 'usage: update_bios_settings.py <yaml>'
  sys.exit(1)

with open(sys.argv[1]) as f:
  siteyaml = yaml.safe_load(f)

# list of background processes created
plist = []

# create set of defaults based on top level ipmi_admin and hardware key/value pairs
defaults = dict( siteyaml["ipmi_admin"].items() + siteyaml["hardware"].items() )

# add keys for backward compatibility
defaults = dict( [('oob_user',siteyaml['ipmi_admin']['username'])]       + defaults.items())
defaults = dict( [('oob_password',siteyaml['ipmi_admin']['password'])]   + defaults.items())

print 'Using defaults:'
for line in yaml.dump(defaults,default_flow_style=False).split('\n'):
    print '    {}'.format(line)

if 'masters' in siteyaml:
    create_node_rcfile(siteyaml["masters"], defaults, "tools/j2/serverrc_raid.j2", "rc.raid")

if 'workers' in siteyaml:
    create_node_rcfile(siteyaml["workers"], defaults, "tools/j2/serverrc_raid.j2", "rc.raid")

# print output from background processes
for p in plist:
    print "waiting for process {}".format(p.pid)
    exitcode=p.wait()
    print 'Process {0} ended with exit code {1}'.format(p.pid, p.returncode)
    print p.communicate()[0]

