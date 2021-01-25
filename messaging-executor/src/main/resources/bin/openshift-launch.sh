#!/bin/bash

JMS_USER=${MESSAGING_USER}
JMS_PASSWORD=${MESSAGING_PASSWORD}

JMS_HOST=${MESSAGING_HOST_VAR}
JMS_HOST=${JMS_HOST^^}
JMS_HOST=${JMS_HOST//-/_}
JMS_HOST=${!JMS_HOST}

SERIALIZER=${MESSAGING_SERIALIZER}
DATA_DIR=/opt/eap/standalone/data
PING_DIR=/opt/mta-cli/ping

echo "Starting executor with messaging server $JMS_HOST as user $JMS_USER"

MTA_OPTS=`/opt/run-java/java-default-options`
export MTA_OPTS="${MTA_OPTS/-XX:MaxMetaspaceSize=100m/-XX:MaxMetaspaceSize=256m}"

echo "MTA_OPTS: $MTA_OPTS"

/opt/mta-cli/bin/mta-cli -Dmessaging.serializer=${MESSAGING_SERIALIZER} \
    -Dwindup.data.dir=${DATA_DIR} \
    --messagingExecutor \
    --user ${JMS_USER} --password ${JMS_PASSWORD} --host ${JMS_HOST} \
    --connectionFactory jms/RemoteConnectionFactory \
    --executorQueue jms/queues/executorQueue \
    --statusUpdateQueue jms/queues/statusUpdateQueue \
    --cancellationTopic jms/topics/executorCancellation \
    --pingDir ${PING_DIR} \
     -Dwindup.result.get.url=http://${JMS_HOST}:8080/mta-ui/api/windup/executions/get-execution-request-tar \
     -Dwindup.result.post.url=http://${JMS_HOST}:8080/mta-ui/api/windup/executions/post-results
