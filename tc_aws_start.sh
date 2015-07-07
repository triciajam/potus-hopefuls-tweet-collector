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


echo "Installing Dependencies"
pip install oauthlib
pip install requests
pip install requests-oauthlib
pip install six
pip install tweepy
pip install wheel
pip install boto
pip install sh

echo "All packages installed."


echo "Making directories."
mkdir -p /tmp
mkdir -p /tmp/twit-candi-2016
echo "Downloading scrips."

# grab the script and JSON files
echo "Retrieving Data"
aws s3 cp s3://twit-candi-2016/dist/ /tmp/dist --recursive

#curl -L -o /tmp/tc_application.py github.com/triciajam/twit-candi-2016/raw/master/tc_application.py
#curl -L -o /tmp/config.json github.com/triciajam/twit-candi-2016/raw/master/config.json


# get the instance id
# INSTANCE_ID=`ec2metadata --instance-id`
 
# terminate the instance - you must specify the region
# aws ec2 terminate-instances --region $region --instance-ids $INSTANCE_ID
