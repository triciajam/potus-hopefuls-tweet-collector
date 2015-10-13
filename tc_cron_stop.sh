#!/bin/bash

# $1 - app name

source $HOME/.bash_profile

datetime=$(date '+%Y%m%d.%H%M%S');
dateonly=$(date -u '+%Y%m%d');

#base_dir=`cat ${script_dir}/config.json | jq -r '.BASE_DIR'`

echo "** $datetime [ TC-STOP ] : Ending ${data_dir}/$1"
pid=`cat ${data_dir}/pid_$1`

kill -9 $pid
echo "** $datetime [ TC-STOP ] : Ended $1 at $pid"

{
  echo "** $datetime [ TC-STOP ] : Removing last incomplete lines from files."
  dirs=`ls -d $data_dir/*/`
  lastfiles=`for d in $dirs; do name=\`ls -t  $d | head -n1\`; echo $d$name ; done` # find very last files
  chour=`date +"%H"`
  cdate=`date +"%Y-%m-%d"`
  lastfilesthishour=`find ${lastfiles[@]} -type f -newerct "${cdate} ${chour}:00:00"` # confirm they were written this hour
  for f in ${lastfilesthishour[@]}; do sed -i '$ d' $f; done
} || {
  echo "** $datetime [ TC-STOP ] : ERROR : While removing last incomplete lines from files."
} 


{
  echo "** $datetime [ TC-STOP ] : Removing tweets beyond the specified minute range."
  chour=`date +"%H"`
  cdate=`date +"%Y-%m-%d"`
  filesthishour=`find ${data_dir}/*/* -type f -newerct "${cdate} ${chour}:00:00"` 
  for f in ${filesthishour[@]}; do 
    linesatend=`cat $f | jq -r '.created_at' | grep ":1[78]:" | wc -l` 
    echo "$f: has $linesatend at end" 
    linesatstart=`cat $f | jq -r '.created_at' | grep ":04:" | wc -l`
    if [[ $linesatstart != 0 ]] ; then
      linesatstart=$((linesatstart + 1))
    fi  
    echo "$f: has $linesatstart at start"
    if [[ $linesatstart != 0 || $linesatend != 0 ]] ; then 
      tail -n +${linesatstart} $f | head -n -${linesatend} > "$f.new" && mv "$f.new" "$f"
    fi 
  done
} || {
  echo "** $datetime [ TC-STOP ] : ERROR : While removing lasttweets beyond the specified minute range."
} 


echo "** $datetime [ TC-STOP ] : Copying files to s3"
#aws s3 cp $1 s3://twit-candi-2016/data/$dt/ --recursive --exclude creds.json
#aws s3 cp $1 s3://twit-candi-2016/data/$dt/ --recursive --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --exclude "tclog" --include "config.json"
#aws s3 sync $base_dir s3://twit-candi-2016/data/$dateonly/ --recursive --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --exclude "tclog" --include "config.json"
aws s3 sync $data_dir s3://twit-candi-2016/data/$dateonly/ --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --include "config.json"

echo "** $datetime [ TC-STOP ] : Files copied"
