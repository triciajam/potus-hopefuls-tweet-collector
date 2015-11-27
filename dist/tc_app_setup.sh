#!/bin/bash

dateonly=$(date '+%Y%m%d');

echo "** ${dateonly} [ TC-SETUP ] : Making data directory at ${data_dir}."
mkdir -p $data_dir
echo "** ${dateonly} [ TC-SETUP ] : Copying scripts to ${data_dir}."
cp ${script_dir}/tc_application.py $data_dir
cp ${script_dir}/creds.json $data_dir
cp ${script_dir}/config.json $data_dir

echo "** ${dateonly} [ TC-SETUP ] : Setting up filesystem in $data_dir."
fd=`cat ${data_dir}/config.json | jq -r '.folders[]'`
echo "** Data folders are $fd"

for f in $fd; do
  mkdir -p ${data_dir}/$f
done  
echo "** ${dateonly} [ TC-SETUP ] : Data folders created."

echo "** ${dateonly} [ TC-SETUP ] : Making scripts executable."
chmod 777 ${data_dir}/tc_application.py