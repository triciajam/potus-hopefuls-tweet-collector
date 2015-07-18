#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Get some information about the running instance
# Amazon Linux, ec2-user

instance_id=$(wget -qO- instance-data/latest/meta-data/instance-id)
public_ip=$(wget -qO- instance-data/latest/meta-data/public-ipv4)
zone=$(wget -qO- instance-data/latest/meta-data/placement/availability-zone)
region=$(expr match $zone '\(.*\).')
uptime=$(uptime)

echo "Working On $instance_id @ $public_ip"

echo "Existing Packages"
which python
python --version
which pip
pip --version
which virtualenv
#sudo alternatives --set python /usr/bin/python2.6


echo "Creating Virtual Environment"
mkdir /tmp/venv
cd /tmp/venv
virtualenv tc
source tc/bin/activate

echo "Upgrading Packages"
yum -y update

echo "Upgrading Pip"
pip install --upgrade pip
#hash -r
#ln -s /usr/local/bin/pip-2.7 /usr/bin/pip 
which python
which pip

echo "Installing jq"
yum -y install jq

echo "Installing Python Dependencies"
pip install oauthlib
pip install requests
pip install requests-oauthlib
pip install six
pip install tweepy
pip install wheel
pip install boto
pip install sh

echo "All packages installed."


echo "Making base directory."
mkdir -p /tmp
mkdir -p /tmp/twit-candi-2016
mkdir -p /tmp/twit-candi-2016/dist

# grab the script and JSON files
echo "Retrieving application scripts."
aws s3 sync s3://twit-candi-2016/dist/ /tmp/twit-candi-2016/dist 
#curl -L -o /tmp/tc_application.py github.com/triciajam/twit-candi-2016/raw/master/tc_application.py
#curl -L -o /tmp/config.json github.com/triciajam/twit-candi-2016/raw/master/config.json

echo "Setting up filesystem."
cd /tmp/twit-candi-2016/dist
chmod 777 tc_application.py

#cat config.json | jq '.folders'
#cat config.json | jq '.folders[]'
#cat config.json | jq '[.folders[]]'

fd=`cat config.json | jq -r '.folders[]'`
echo "Data folders to create are $fd"

for f in $fd; do
  mkdir -p /tmp/twit-candi-2016/dist/$f
done  
echo "Data folders created."

echo "Setting up cron."
crontab -l
dt=$(date '+%Y%m%d.%H%M%S');
echo "0 */3 * * * root aws s3 cp /tmp/twit-candi-2016/dist s3://twit-candi-2016/data/$dt/ --recursive --exclude creds.json" >> /etc/crontab
crontab -l

echo "Starting application."
python tc_application.py

# get the instance id
# INSTANCE_ID=`ec2metadata --instance-id`
 
# terminate the instance - you must specify the region
# aws ec2 terminate-instances --region $region --instance-ids $INSTANCE_ID
