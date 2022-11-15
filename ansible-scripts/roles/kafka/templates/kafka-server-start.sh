#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ $# -lt 1 ];
then
	echo "USAGE: $0 [-daemon] server.properties [--override property=value]*"
	exit 1
fi
base_dir=$(dirname $0)

if [ "x$KAFKA_LOG4J_OPTS" = "x" ]; then
    export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$base_dir/../config/log4j.properties"
fi

if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    # export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
    export KAFKA_HEAP_OPTS="-Xmx{{ KAFKA_HEAP_SIZE }} -Xms{{ KAFKA_HEAP_SIZE }}"
fi

#Adding Jolokia JVM agent as part of Kafka build.
export JMX_PORT=9999
export KAFKA_JMX_OPTS="-javaagent:/opt/ns/kafka/libs/jolokia-agent.jar=port=8778,host=localhost -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname={{ inventory_hostname_short }}.{{ dns_domain }} -Dcom.sun.management.jmxremote.rmi.port=$JMX_PORT"



# nk NOTE:
#This feature is exactly retained from the Kafka 1.0.1-ns15
# The value of `KAFKA_JVM_PERFORMANCE_OPTS` is customized here rather than in kafka-run-class.sh.
#
# Rationale:
# Both KAFKA_HEAP_OPTS and KAFKA_JVM_PERFORMANCE_OPTS should be set in the same place for consistency.
# The code in kafka-run-class.sh already explicitly checks if these values are overridden by the caller.
# The only time/place we want to override the defaults is for the main Kafka entry point when we're running
# a broker. The rest of the time kafka-run-class.sh is called when doing ad-hoc maintenance, in which case the
# the default JVM values are almost always fine. So we override the defaults in the kafka-server-start.sh,
# which then overrides the defaults in kafka-run-class.sh.
#
# The java.rmi.server.hostname param was required to access the JMX server using Jconsole/VisualVM.
# Even though I was using SSH port forwarding, setting it to localhost or 127.0.0.1 didn't work, only the FQDN worked.
if [ "x$KAFKA_JVM_PERFORMANCE_OPTS" = "x" ]; then
    {# have to use multiple vars to build the java.rmi.server.hostname rather than Ansible var inventory_hostname because in production inventory_hostname includes ".mgt." #}
    export KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -Djava.awt.headless=true -Dcom.sun.management.jmxremote.rmi.port=9999 -Djava.rmi.server.hostname={{ inventory_hostname_short }}.{{ dns_domain }}"
fi

if [ "x$JMX_PORT" = "x" ]; then
    export JMX_PORT=9999
fi

EXTRA_ARGS=${EXTRA_ARGS-'-name kafkaServer -loggc'}

COMMAND=$1
case $COMMAND in
  -daemon)
    EXTRA_ARGS="-daemon "$EXTRA_ARGS
    shift
    ;;
  *)
    ;;
esac

exec $base_dir/kafka-run-class.sh $EXTRA_ARGS kafka.Kafka "$@"
