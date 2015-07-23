#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

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
mkdir -p /tmp/scripts
cd /tmp/scripts
echo "** Retrieving application scripts"
aws s3 sync s3://twit-candi-2016/dist/ . 
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

echo "** Changing permissions and ownership."
chmod 777 tc_application.py
chmod 777 tc_cron_start.sh
chmod 777 tc_cron_stop.sh
chown -R ec2-user:ec2-user $base_dir

echo "** Setting up cron."
dt=$(date '+%Y%m%d.%H%M%S');
# run every hour
echo "3 */1 * * * ec2-user ${base_dir}tc_cron_start.sh ${base_dir} tc_application.py >> ${base_dir}tclog 2>&1" >> /etc/crontab
echo "16 */1 * * * ec2-user ${base_dir}tc_cron_stop.sh ${base_dir} tc_application.py >> ${base_dir}tclog 2>&1" >> /etc/crontab
#echo "13 */1 * * * root aws s3 cp /tmp/twit-candi-2016/dist s3://twit-candi-2016/data/$dt/ --recursive --exclude creds.json" >> /etc/crontab
cat /etc/crontab
#echo "Starting application."
#python tc_application.py
