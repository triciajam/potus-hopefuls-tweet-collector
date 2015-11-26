#!/bin/bash

# $1 - app name

source $HOME/.bash_profile

datetime=$(date -u '+%Y-%m-%d.%H-%M-%S');
dateonly=$(date -u '+%Y%m%d');
details="${log_dir}/${datetime}.details"

#base_dir=`cat ${script_dir}/config.json | jq -r '.BASE_DIR'`

echo "** $datetime [ TC-STOP ] : Ending ${data_dir}/$1"
pid=`cat ${data_dir}/pid_$1`

kill -9 $pid
echo "** $datetime [ TC-STOP ] : Ended $1 at $pid"


dirs=`ls -d $data_dir/*/`
lastfiles=( `for d in $dirs; do name=\`ls -t  $d | head -n1\`; echo $d$name ; done` ) # find very last files
echo "** $datetime [ TC-STOP ] : There are ${#lastfiles[@]} last files (max 1 in each folder)."  

chour=`date +"%H"`
cdate=`date +"%Y-%m-%d"`
lastfilesthishour=( `find ${lastfiles[@]} -type f -newerct "${cdate} ${chour}:00:00"` ) # confirm they were written this hour
echo "** $datetime [ TC-STOP ] : There were ${#lastfilesthishour[@]} last files written this hour."	

filesthishour=( `find ${data_dir}/*/* -type f -newerct "${cdate} ${chour}:00:00"` )
echo "** $datetime [ TC-STOP ] : There were ${#filesthishour[@]} files written this hour."

if [[ ${#lastfilesthishour[@]} -ne 0 ]]; then
  echo "** $datetime [ TC-STOP ] : Removing incomplete lines from last files written this hour."
  {
    for f in ${lastfilesthishour[@]}; do 
      echo "removing last line from $f" >> $details
      sed -i '$ d' $f >> $details 2>&1 
    done
  } && {
    echo "** $datetime [ TC-STOP ] : SUCCESS : Removed last incomplete lines from ${#lastfilesthishour[@]} files."
  } || {
    echo "** $datetime [ TC-STOP ] : ERROR : While removing last incomplete lines from files."
  } 
fi

if [[ ${#filesthishour[@]} -ne 0 ]]; then

  echo "** $datetime [ TC-STOP ] : Removing tweets beyond the specified range from files written this hour."
  
  for f in ${filesthishour[@]}; do 
    linesatend=`cat $f | jq -r '.created_at' | grep ":1[78]:" | wc -l` 
    echo "$f: has $linesatend at end" >> $details
    linesatstart=`cat $f | jq -r '.created_at' | grep ":04:" | wc -l`
    if [[ $linesatstart != 0 ]] ; then
      linesatstart=$((linesatstart + 1))
    fi  
    echo "$f: has $linesatstart at start" >> $details
    if [[ $linesatstart != 0 || $linesatend != 0 ]] ; then 
      {
        tail -n +${linesatstart} $f | head -n -${linesatend} > "$f.new" && mv "$f.new" "$f"
      } || {
        echo "** $datetime [ TC-STOP ] : ERROR : While removing tweets from $f .";
      }
    fi  
  done
  
fi

#} && {
#  echo "** $datetime [ TC-STOP ] : SUCCESS : Removed last tweets beyond the specified time range."
#} || {
#  
#} 


#echo "** $datetime [ TC-STOP ] : Removing last line of most recent files"
#cd $data_dir
#fd=`for f in */; do echo $f; done`
#lastones=`for f in */; do fname=\`ls -t $f | head -n1 \`; echo $f$fname; done`
#echo "** $datetime [ TC-STOP ] : Files to change are are $lastones"
#for f in $lastones; do
#  sed -i '$ d' $f
#done

echo "** $datetime [ TC-STOP ] : Copying files to s3"
#aws s3 cp $1 s3://twit-candi-2016/data/$dt/ --recursive --exclude creds.json
#aws s3 cp $1 s3://twit-candi-2016/data/$dt/ --recursive --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --exclude "tclog" --include "config.json"
#aws s3 sync $base_dir s3://twit-candi-2016/data/$dateonly/ --recursive --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" --exclude "tclog" --include "config.json"

{
  aws s3 sync $data_dir s3://twit-candi-2016/data/$dateonly/ --exclude "*.json" --exclude "*.sh" --exclude "*.py" --exclude "pid*" >> $details 2>&1
} && {
  numupload=`cat $details | grep "upload" | wc -l `
  echo "** $datetime [ TC-STOP ] : SUCCESS : Copied all $numupload files to S3."
} || {
  numupload=`cat $details | grep "upload" | wc -l `
  echo "** $datetime [ TC-STOP ] : ERROR : Copied only $numupload files to S3."
}
if [[ "$numupload" -ne "${#filesthishour[@]}" ]]; then
  echo "** $datetime [ TC-STOP ] : ERROR : Num new files ( ${#filesthishour[@]} ) does not match number copied to AWS ( ${numupload} )."  
fi
