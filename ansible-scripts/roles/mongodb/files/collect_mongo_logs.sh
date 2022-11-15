#!/bin/bash
PTDEST=/tmp/pt/collected/`hostname`/
mkdir -p $PTDEST;
cd /tmp/pt;
wget percona.com/get/pt-summary;
chmod +x pt*;
sudo ./pt-summary > $PTDEST/pt-summary.out;

# Adjust port, user and password
MONGO_AUTH=" --port 27018 -u cluster_admin -p "S3cur3Th3Cl0ud"  --authenticationDatabase admin"

mongo $MONGO_AUTH --eval "db.adminCommand( { getParameter : '*' } )" > $PTDEST/getParameter.out;
mongo $MONGO_AUTH --eval "db.adminCommand( { getCmdLineOpts : 1 } )" > $PTDEST/getCmdLineOpts.out;
mongo $MONGO_AUTH --eval "db.serverStatus()" > $PTDEST/serverStatus.out;
mongo $MONGO_AUTH --eval "db.hostInfo()" > $PTDEST/host_info.out;
mongo $MONGO_AUTH --eval "printjson(db.adminCommand({'currentOp': true}))" > $PTDEST/currentOp.out;

# For replicaSet (please ignore below commands if it is not applicable):
mongo $MONGO_AUTH --eval "rs.status()" > $PTDEST/rs_status.out;
mongo $MONGO_AUTH --eval "rs.conf()" > $PTDEST/rs_conf.out;
mongo $MONGO_AUTH --eval "rs.printReplicationInfo()" > $PTDEST/rs_printReplicationInfo.out;
mongo $MONGO_AUTH --eval "rs.printSlaveReplicationInfo()" > $PTDEST/rs_printSlaveReplicationInfo.out;

## For sharded Cluster - mongos (please ignore below command if it is not applicable):
#mongo $MONGO_AUTH --eval "sh.status()" > $PTDEST/sh_status.out;

# IO related
sudo lsblk --all > $PTDEST/lsblk-all;

# nfsstat for systems with NFS mounts
sudo nfsstat -m > $PTDEST/nfsstat_m;
sudo nfsiostat 1 120 > $PTDEST/nfsiostat;

sudo sysctl -a > $PTDEST/sysctl;
sudo dmesg >  $PTDEST/dmesg;
sudo dmesg -T >  $PTDEST/dmesg_t;
ulimit -a > $PTDEST/ulimit_a;
sudo numactl --hardware  >  $PTDEST/numactl-hardware;
sudo tar -cvf diagnostics.tar.gz /data/diagnostic.data
sudo ar -cvf mongodb.log.tar.gz /var/log/mongodb/mongodb.log
