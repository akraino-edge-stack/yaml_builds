#!/usr/local/bin/python
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

#
#  jcopy.py - Copy a file or files to a target directory, making
#    substitutions as needed from the values contained in a YAML file.
#
#  usage: jcopy.py <yaml> <in_dir_or_file> <out_dir>
#
#  Note: jcopy.sh is for Python2, jcopy3.sh is for Python3
#

import os.path
import jinja2
import sys
import yaml

def expand_files(target_dir, dir_name, files):
	global total
	xlen = len(sys.argv[2])
	targdir = target_dir + dir_name[xlen:]
	if not os.path.exists(targdir):
		os.makedirs(targdir)
	env = jinja2.Environment()
	for f in files:
		source_path = dir_name + '/' + f
		target_path = targdir + '/' + f
		if os.path.isfile(source_path):
			with open(source_path) as fd:
				template = env.from_string(fd.read())
			data = template.render(yaml=yaml)
			fd2 = open(target_path,'w')
			fd2.write(data)
			fd2.close()
			total += 1

def expand_file(target_dir, file):
	global total
	if not os.path.exists(target_dir):
		os.makedirs(target_dir)
	env = jinja2.Environment()
	with open(file) as fd:
		template = env.from_string(fd.read())
	data = template.render(yaml=yaml)
	target_path = target_dir + '/' + os.path.basename(file)
	fd2 = open(target_path,'w')
	fd2.write(data)
	fd2.close()
	total += 1

if len(sys.argv) != 4:
	print('usage: jcopy.py <yaml> <in_dir_or_file> <out_dir>')
	sys.exit(1)

with open(sys.argv[1]) as f:
	yaml = yaml.safe_load(f)

total = 0
if os.path.isfile(sys.argv[2]):
	expand_file(sys.argv[3], os.path.abspath(sys.argv[2]))
else:
	for root, dirs, files in os.walk(sys.argv[2]):
		expand_files(sys.argv[3], root, files)
print('%d files processed.' % total)
sys.exit(0)
