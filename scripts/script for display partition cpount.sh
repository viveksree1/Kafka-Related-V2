#!/bin/bash
sum=0;
#var='"Leader: '$num'"';
for i in $(/opt/ns/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper01:2181 );
do
echo $(/opt/ns/kafka/bin/kafka-topics.sh --describe --zookeeper zookeeper01:2181 --topic $i | grep 'PartitionCount' | awk '{print $1,$2}')
done