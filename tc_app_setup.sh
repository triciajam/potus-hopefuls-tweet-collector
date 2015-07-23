#!/bin/bash

cd /tmp/scripts
base_dir=`cat config.json | jq -r '.BASE_DIR'`

echo "** Making base directory at $base_dir."
mkdir -p $base_dir
echo "** Copying scripts to $base_dir."
cp -R /tmp/scripts/. $base_dir
echo "** Setting up filesystem in $base_dir."
cd $base_dir
fd=`cat config.json | jq -r '.folders[]'`
echo "** Data folders are $fd"

for f in $fd; do
  mkdir -p $base_dir$f
done  
echo "** Data folders created."

echo "** Making scripts executable"
chmod 777 tc_application.py
chmod 777 tc_cron_start.sh
chmod 777 tc_cron_stop.sh
