#!/bin/bash
#Author:- Vivek <vsrikumar@nk.com>
date
mongo_pid=`pidof mongod`
hostfqdn=`nslookup $(hostname) | grep Name | awk {'print $2'}`
host=`echo $hostfqdn | sed -e 's/^sv5//g; s/^am2//g; s/^fr4//g; s/^sjc1//g'`
perc=`df -h /var/log | tail -n 1 | awk {'print $5'} | sed -e 's/%//g'`
if [ $perc -eq 100 ] ; then
   echo "/var/log is full in $host. Clearing mongodb log"
   sudo rm -rf /var/log/mongodb/mongodb.log*
   timeout 5s mongo --port 27018 --eval 'db.adminCommand({logRotate:1})'
fi
if [ -z "$mongo_pid" ] ; then
 echo "Mongo is not running"
 exit 0
fi
timeout 5s mongo --port 27018 --eval 'rs.printSlaveReplicationInfo()'
if [ $? -eq 0 ] ; then
max_cache=`mongo --port 27018 --quiet --eval 'db.serverStatus()["wiredTiger"]["cache"]["maximum bytes configured"]'`
curr_cache=`mongo --port 27018 --quiet --eval 'db.serverStatus()["wiredTiger"]["cache"]["bytes currently in the cache"]'`
cache=`echo "scale=2; $curr_cache/$max_cache * 100" | bc -l | cut -d. -f 1`
if [ $cache -gt 93 ] ; then
   echo "Cache utilization seems high at $cache for $host. Trying stepdown"
   mongo --port 27018 --eval 'rs.stepDown(1800)'
   if [ $? -eq 0 ] ; then
      echo "Stepdown succeeded in $host"
   fi
fi
fi
SECONDS=0
timeout 45s mongo --port 27018 --eval 'rs.printSlaveReplicationInfo()'
timeout_exit_status=$?
if [ $timeout_exit_status -ne 0 ] && [ $SECONDS -lt 10 ] ; then
   sleep 40
fi
if [ $timeout_exit_status -ne 0 ] ; then
  echo "Shard $host is hung"
  mongo_pid=`pidof mongod`
  ppid=`ps -o ppid= -p $mongo_pid`
  elapsed=`ps -p $mongo_pid -o etimes | tail -n 1 | awk {'print $1'}`
  if [ $elapsed -gt 900 ] ; then
     time=`date +"%b %d %T %Z"`
     ps -ef | grep mongo | grep "service mongod stop" | grep -v grep
     if [ $? -eq 0 ] ; then
       echo "Restarter already running. Skipping restart on $host at $time"
       exit 0
     fi
     curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "description": "'"Mongo hung in ${host}"'","duration": "1h","hosts": "'"${host}"'","name": "'"Restart ${host} at ${time}"'","start_delay": "0m","ticket": "DIO-3585"}' 'https://nsmonapi.nskope.net/api/v1/zabbix/squelch'
     printf "\n"
     echo "Restarting mongod in $host at $time "
     sudo kill -9 $mongo_pid &>/dev/null
     sudo kill -9 $ppid &>/dev/null
     while [ ! -z $mongo_pid  ]
     do
       mongo_pid=`pidof mongod`
       sudo kill -9 $mongo_pid &>/dev/null
       sudo kill -9 $ppid &>/dev/null
     done
     sudo service mongod start
  fi
fi
