#!/bin/bash

JMS_USER=${MESSAGING_USER}
JMS_PASSWORD=${MESSAGING_PASSWORD}

JMS_HOST=${MESSAGING_HOST_VAR}
JMS_HOST=${JMS_HOST^^}
JMS_HOST=${JMS_HOST//-/_}
JMS_HOST=${!JMS_HOST}

DATA_DIR=/opt/rhamt-cli/data
PING_DIR=/opt/rhamt-cli/ping

echo "Starting executor with messaging server $JMS_HOST as user $JMS_USER"

RHAMT_OPTS=`/opt/run-java/java-default-options`

/opt/rhamt-cli/bin/rhamt-cli -Dmessaging.serializer=amq.largemessage \
    -Dwindup.data.dir=${DATA_DIR} \
    --messagingExecutor \
    --user ${JMS_USER} --password ${JMS_PASSWORD} --host ${JMS_HOST} \
    --connectionFactory jms/RemoteConnectionFactory \
    --executorQueue jms/queues/executorQueue \
    --statusUpdateQueue jms/queues/statusUpdateQueue \
    --cancellationTopic jms/topics/executorCancellation \
    --pingDir ${PING_DIR}
