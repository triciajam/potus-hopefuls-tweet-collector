#!/bin/bash

# $1 - app name

datetime=$(date '+%Y%m%d.%H%M%S');
dateonly=$(date '+%Y%m%d');
script_dir="/tmp/scripts"
log_dir="/tmp/log"
old_dir="/tmp/old"

base_dir=`cat ${script_dir}/config.json | jq -r '.BASE_DIR'`

pid=`cat ${base_dir}pid_$1`

echo "** $datetime: Ending $pid"
kill -9 $pid
echo "** Killed process $pid"

echo "** Removing last line of most recent files"
cd $base_dir
fd=`for f in */; do echo $f; done`
lastones=`for f in */; do fname=\`ls -t $f | head -n1 \`; echo $f$fname; done`
echo "** Files to change are are $lastones"
for f in $lastones; do
  sed -i '$ d' $f
done

echo "** Copying files to s3"
#aws s3 cp $1 s3://twit-candi-2016/data/$dt/ --recursive --exclude creds.json
#aws s3 cp $1 s3://twit-candi-2016/data/$dt/ --recursive --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --exclude "tclog" --include "config.json"
#aws s3 sync $base_dir s3://twit-candi-2016/data/$dateonly/ --recursive --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --exclude "tclog" --include "config.json"
aws s3 sync $base_dir s3://twit-candi-2016/data/$dateonly/ --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --include "config.json"