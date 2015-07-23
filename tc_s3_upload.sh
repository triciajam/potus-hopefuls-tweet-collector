#!/bin/bash

#. tc_s3_upload.sh twit-candi-2016/dist/ 
BUCKET="$1"

echo "prepare local files"
cd ~/Desktop/Projects/twitcamp/
rm -r dist
mkdir dist
cp -a creds.json dist/
cp -a config.json dist/
cp -a tc_application.py dist/
cp -a tc_app_setup.sh dist/
cp -a tc_app_daily_clean.sh dist/
cp -a tc_cron_start.sh dist/
cp -a tc_cron_stop.sh dist/

echo "transferring to ${BUCKET}:"
aws s3 sync dist s3://${BUCKET}
