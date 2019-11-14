#!/bin/bash

set -x
TIMESTAMP=$(date +"%Y%m%d%H%M")
LOGFILE=/var/log/update_software_$TIMESTAMP.log
echo "logging to $LOGFILE"
exec 1> >(tee -a $LOGFILE)
exec 2>&1

# Site specific variables
export OS_AUTH_URL="http://iam-sw.vran.k2.ericsson.se:80/v3"
export OS_USERNAME=shipyard
export OS_PASSWORD=password123
REGION_NAME=MTN3

tools/airship shipyard create configdocs ${REGION_NAME} --directory=/target/configs/promenade

tools/airship shipyard commit configdocs

tools/airship shipyard create action update_software

tools/airship shipyard get actions

# Monitor the workflow
#SHIPYARD_ACTION=$(tools/airship shipyard get actions | awk '/update_software/ {print $2};')
#tools/airship shipyard describe $SHIPYARD_ACTION

