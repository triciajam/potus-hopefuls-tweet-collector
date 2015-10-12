#!/bin/bash

# $1 - app name

source $HOME/.bash_profile

datetime=$(date '+%Y%m%d.%H%M%S');
dateonly=$(date '+%Y%m%d');

#base_dir=`cat ${script_dir}/config.json | jq -r '.BASE_DIR'`

echo "** $datetime [ TC-STOP ] : Ending ${data_dir}/$1"
pid=`cat ${data_dir}/pid_$1`

kill -9 $pid
echo "** $datetime [ TC-STOP ] : Ended $1 at $pid"

echo "** $datetime [ TC-STOP ] : Removing last line of most recent files"
cd $data_dir
fd=`for f in */; do echo $f; done`
lastones=`for f in */; do fname=\`ls -t $f | head -n1 \`; echo $f$fname; done`
echo "** $datetime [ TC-STOP ] : Files to change are are $lastones"
for f in $lastones; do
  sed -i '$ d' $f
done

echo "** $datetime [ TC-STOP ] : Copying files to s3"
#aws s3 cp $1 s3://twit-candi-2016/data/$dt/ --recursive --exclude creds.json
#aws s3 cp $1 s3://twit-candi-2016/data/$dt/ --recursive --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --exclude "tclog" --include "config.json"
#aws s3 sync $base_dir s3://twit-candi-2016/data/$dateonly/ --recursive --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --exclude "tclog" --include "config.json"
aws s3 sync $data_dir s3://twit-candi-2016/data/$dateonly/ --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --include "config.json"

echo "** $datetime [ TC-STOP ] : Files copied"
