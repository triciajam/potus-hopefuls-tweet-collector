#!/bin/bash

datetime=$(date '+%Y%m%d.%H%M%S');
base_dir=`cat /tmp/scripts/config.json | jq -r '.BASE_DIR'`
archive_dir="/tmp/old/${datetime}"

echo "** Archiving current base directory $base_dir at archive ${archive_dir}."
mkdir -p $archive_dir
cp -R ${base_dir}. ${archive_dir}/

echo "** Removing current base directory at $base_dir"
rm -r ${base_dir}

echo "** Making new base directory"
. /tmp/scripts/tc_app_setup.sh

echo "** All done"
