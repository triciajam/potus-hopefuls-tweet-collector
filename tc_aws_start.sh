#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

script_dir="/tmp/scripts"
log_dir="/tmp/log"
old_dir="/tmp/old"

# Get some information about the running instance
# Amazon Linux, ec2-user

instance_id=$(wget -qO- instance-data/latest/meta-data/instance-id)
public_ip=$(wget -qO- instance-data/latest/meta-data/public-ipv4)
zone=$(wget -qO- instance-data/latest/meta-data/placement/availability-zone)
region=$(expr match $zone '\(.*\).')
uptime=$(uptime)

echo "** Working On $instance_id @ $public_ip"

echo "** Existing Packages"
echo "python: "`which python`
echo "python version: "`python --version`
echo "pip: "`which pip`
echo "pip version: "`pip --version`
echo "virtualenv: "`which virtualenv`
echo "virtualenv version: "`virtualenv --version`

#sudo alternatives --set python /usr/bin/python2.6

echo "** Creating Virtual Environment"
mkdir /tmp/venv
cd /tmp/venv
virtualenv tc
source tc/bin/activate

echo "** Upgrading Packages"
yum -y update

echo "** Upgrading Pip"
pip install --upgrade pip
#hash -r
#ln -s /usr/local/bin/pip-2.7 /usr/bin/pip 

echo "** Installing jq"
yum -y install jq

echo "** Installing Python Dependencies"
pip install oauthlib
pip install requests
pip install requests-oauthlib
pip install six
pip install tweepy
pip install wheel
pip install boto
pip install sh

echo "** All packages installed."

echo "** Current Package Locations"
echo "python: "`which python`
echo "python version: "`python --version`
echo "pip: "`which pip`
echo "pip version: "`pip --version`
echo "virtualenv: "`which virtualenv`
echo "virtualenv version: "`virtualenv --version`

# grab the script and JSON files
mkdir -p $script_dir
cd $script_dir
echo "** Retrieving application scripts"
aws s3 sync s3://twit-candi-2016/dist/ . 
chmod 777 *.py
chmod 777 *.sh

echo "** Setting up app"
. ${script_dir}/tc_app_setup.sh

echo "** Making backup directory"
mkdir -p $old_dir
echo "** Making log directory"
mkdir -p $log_dir

echo "** Setting owner to ec2-user"
chown -R ec2-user:ec2-user $script_dir
chown -R ec2-user:ec2-user $old_dir
chown -R ec2-user:ec2-user $log_dir
chown -R ec2-user:ec2-user $base_dir

echo "** Setting up cron."
dt=$(date '+%Y%m%d.%H%M%S');
# run every hour

{ crontab -l -u ec2-user; echo "1 */1 * * * ${script_dir}/tc_cron_start.sh tc_application.py >> ${log_dir}/crlog 2>&1"; } | crontab -u ec2-user -
{ crontab -l -u ec2-user; echo "13 */1 * * * ${script_dir}/tc_cron_stop.sh tc_application.py >> ${log_dir}/crlog 2>&1"; } | crontab -u ec2-user -
{ crontab -l -u ec2-user; echo "30 23 * * * ${script_dir}/tc_app_daily_clean.sh >> ${log_dir}cleanlog 2>&1"; } | crontab -u ec2-user -

crontab -l -u ec2-user

#crontab -e to edit
#echo "Starting application."
#python tc_application.py
