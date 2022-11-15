#!/bin/bash
sum=0;
echo "Enter the leader number:";
read num;
#var='"Leader: '$num'"';
for i in $(/opt/ns/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper01:2181 );
do
#count=$(eval "/opt/ns/kafka/bin/kafka-topics.sh --describe --zookeeper zookeeper01:2181 --topic $i |grep $var | wc -l"); 
count=$(eval "/opt/ns/kafka/bin/kafka-topics.sh --describe --zookeeper zookeeper01:2181 --topic $i |grep \"Leader: $num\" | wc -l");
sum=`expr $sum + $count` ;
echo 'total partitions for' $i 'is: ' $count;
done
echo 'Overall partitions for is: ' $sum;