#!/bin/bash

source $HOME/.bash_profile

dateonly=$(date '+%Y%m%d');
datetime=$(date '+%Y%m%d.%H%M%S');
#base_dir=`cat /tmp/scripts/config.json | jq -r '.BASE_DIR'`
archive_dir="${old_dir}/${dateonly}"

echo "** ${dateonly} [ TC-CLEAN ] : Archiving current base directory $data_dir at archive ${old_dir}."
mkdir -p $archive_dir
cp -R ${data_dir}/* ${archive_dir}/

echo "** ${dateonly} [ TC-CLEAN ] : Removing current data directory at $data_dir"
rm -r ${data_dir}
echo "** ${dateonly} [ TC-CLEAN ] : Making new base directory"
. ${script_dir}/tc_app_setup.sh

echo "** ${dateonly} [ TC-CLEAN ] : All done"
