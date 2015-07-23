#!/bin/bash

# $1 - app name

script_dir="/tmp/scripts"
log_dir="/tmp/log"
old_dir="/tmp/old"
base_dir=`cat ${script_dir}/config.json | jq -r '.BASE_DIR'`

dt=$(date '+%Y%m%d.%H%M%S');
echo "** $dt: Starting ${base_dir}$1"

source /tmp/venv/tc/bin/activate
cd $base_dir
python $1 > ${log_dir}/pylog 2>&1 &
echo $! > "${base_dir}pid_$1"

echo "** Wrote pid $pid for $1 in ${base_dir}pid_$1"