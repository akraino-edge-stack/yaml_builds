#!/usr/bin/python
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

#  jcopy.py - Copy a file or files to a target directory, making
#    substitutions as needed from the values contained in a YAML file.
#    compatibile with python and python3
#
#  usage: jcopy.py <yaml_input> <template_dir_or_file> <out_dir>

import os.path
import jinja2
import sys
import yaml

def usage(msg=None):
  if not msg is None:
    print(msg)
  print( 'usage: jcopy.py <yaml> <template_dir_or_file> <out_dir>' )
  sys.exit(1)

def expand_template( t, output_fname, fill=60 ):
  print( '### {0: <{fill}} ==> {1}'.format(t.filename, output_fname, fill=fill) )
  if not os.path.exists(os.path.dirname(output_fname)):
    os.makedirs(os.path.dirname(output_fname))
  t.stream(yaml=siteyaml).dump(output_fname)

if len(sys.argv) != 4:
  usage('incorrect number of arguments')

yaml_input=sys.argv[1]
j2in_name=sys.argv[2]
yaml_out=sys.argv[3]

if not os.path.isfile(yaml_input):
  usage('input yaml file {} does not exist'.format(yaml_input))

with open(yaml_input) as f:
  siteyaml = yaml.safe_load(f)

if os.path.isfile(j2in_name):
  j2_env = jinja2.Environment(loader=jinja2.FileSystemLoader(os.path.dirname(j2in_name)), trim_blocks=True, lstrip_blocks=True, undefined=jinja2.make_logging_undefined())
  expand_template(j2_env.get_template(name=os.path.basename(j2in_name)),yaml_out,len(j2in_name))
else:
  j2_env = jinja2.Environment(loader=jinja2.FileSystemLoader(j2in_name), trim_blocks=True, lstrip_blocks=True, undefined=jinja2.make_logging_undefined())
  templates=j2_env.list_templates(extensions=('j2'))
  fill=len(max(templates,key=len))+len(j2in_name)
  for f in templates:
    expand_template(j2_env.get_template(name=f), yaml_out+'/'+f.replace('.j2','.yaml'), fill)
  print('%d files processed.' % len(templates))

sys.exit(0)

# sudo apt-get install python-jinja2 python-yaml
# sudo apt-get install python3-jinja2 python3-yaml

