#!/bin/bash

# $1 - app name

# should check here to make sure all directories exist.....

source $HOME/.bash_profile

dt=$(date -u '+%Y-%m-%d.%H-%M-%S');
echo "** $dt [ TC-START ] : Starting ${data_dir}/$1"

source ${app_dir}/venv/tc/bin/activate
cd ${data_dir}
python  $1 > ${log_dir}/pylog 2>&1 &
pid=`echo $!`
echo $pid > "${data_dir}/pid_$1"

echo "** $dt [ TC-START ] : Started $1 at process $pid"  
