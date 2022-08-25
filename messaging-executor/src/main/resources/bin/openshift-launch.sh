#!/bin/bash

JMS_USER=${MESSAGING_USER}
JMS_PASSWORD=${MESSAGING_PASSWORD}

JMS_HOST=${MESSAGING_HOST_VAR}
JMS_HOST=${JMS_HOST^^}
JMS_HOST=${JMS_HOST//-/_}
JMS_HOST=${!JMS_HOST}

SERIALIZER=${MESSAGING_SERIALIZER}
DATA_DIR=/opt/windup/data
PING_DIR=/opt/windup-cli/ping

echo "Starting executor with messaging server $JMS_HOST as user $JMS_USER"

WINDUP_OPTS=`/opt/run-java/java-default-options`
export WINDUP_OPTS="${WINDUP_OPTS/-XX:MaxMetaspaceSize=100m/-XX:MaxMetaspaceSize=256m}"

echo "WINDUP_OPTS: $WINDUP_OPTS"

/opt/windup-cli/bin/windup-cli -Dmessaging.serializer=${MESSAGING_SERIALIZER} \
    -Dwindup.data.dir=${DATA_DIR} \
    --messagingExecutor \
    --user ${JMS_USER} --password ${JMS_PASSWORD} --host ${JMS_HOST} \
    --connectionFactory jms/RemoteConnectionFactory \
    --executorQueue jms/queues/executorQueue \
    --statusUpdateQueue jms/queues/statusUpdateQueue \
    --cancellationTopic jms/topics/executorCancellation \
    --pingDir ${PING_DIR} \
     -Dwindup.result.get.url=http://${JMS_HOST}:8080/windup-ui/api/windup/executions/get-execution-request-tar \
     -Dwindup.result.post.url=http://${JMS_HOST}:8080/windup-ui/api/windup/executions/post-results
