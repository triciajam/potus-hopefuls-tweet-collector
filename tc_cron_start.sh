#!/bin/bash

dt=$(date '+%Y%m%d.%H%M%S');
echo "** $dt: Starting $1$2"

source /tmp/venv/tc/bin/activate
cd $1
python $2 &
echo $! > "${1}pid_$2"

echo "** Wrote pid $pid for $2 in ${1}pid_$2"