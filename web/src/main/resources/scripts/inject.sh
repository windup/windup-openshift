#!/usr/bin/env bash

#mkdir -p ${JBOSS_HOME}/standalone/log

echo "Installing keycloak server"
unzip -o -d ${JBOSS_HOME} /opt/tools/keycloak-server-overlay/keycloak-server-overlay-*.zip
sed -i 's#embed-server --server-config=standalone.xml#embed-server --server-config=standalone-openshift.xml#g' ${JBOSS_HOME}/bin/keycloak-install.cli

echo "Running keycloak server CLI script"
${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/bin/keycloak-install.cli

#echo "Installing keycloak client adapters"
#unzip -o -d ${JBOSS_HOME} /opt/tools/keycloak-client-overlay/keycloak-wildfly-adapter-dist-*.zip
#sed -i 's#embed-server --server-config=${server.config:standalone.xml}#embed-server --server-config=${server.config:standalone-openshift.xml}#g' ${JBOSS_HOME}/bin/adapter-install-offline.cli
#${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/bin/adapter-install-offline.cli

echo "Running local CLI script for configuring logging, queues, and keycloak client realm"
# Run our CLI script (logging and keycloak configuration)
#sed -i 's#<subsystem xmlns="urn:jboss:domain:messaging-activemq:13.0"/>#<subsystem xmlns="urn:jboss:domain:messaging-activemq:13.0"><server name="default"><journal pool-files="10"/><statistics enabled="${wildfly.messaging-activemq.statistics-enabled:${wildfly.statistics-enabled:false}}"/><security-setting name="\#"><role name="guest" send="true" consume="true" create-non-durable-queue="true" delete-non-durable-queue="true"/></security-setting><address-setting name="\#" dead-letter-address="jms.queue.DLQ" expiry-address="jms.queue.ExpiryQueue" max-size-bytes="10485760" page-size-bytes="2097152" message-counter-history-day-limit="10" redistribution-delay="1000"/><http-connector name="http-connector" socket-binding="http-messaging" endpoint="http-acceptor"/><http-connector name="http-connector-throughput" socket-binding="http-messaging" endpoint="http-acceptor-throughput"><param name="batch-delay" value="50"/></http-connector><in-vm-connector name="in-vm" server-id="0"><param name="buffer-pooling" value="false"/></in-vm-connector><http-acceptor name="http-acceptor" http-listener="default"/><http-acceptor name="http-acceptor-throughput" http-listener="default"><param name="batch-delay" value="50"/><param name="direct-deliver" value="false"/></http-acceptor><in-vm-acceptor name="in-vm" server-id="0"><param name="buffer-pooling" value="false"/></in-vm-acceptor><jms-queue name="ExpiryQueue" entries="java:/jms/queue/ExpiryQueue"/><jms-queue name="DLQ" entries="java:/jms/queue/DLQ"/><connection-factory name="InVmConnectionFactory" entries="java:/ConnectionFactory" connectors="in-vm"/><connection-factory name="RemoteConnectionFactory" entries="java:jboss/exported/jms/RemoteConnectionFactory" connectors="http-connector" reconnect-attempts="-1"/><pooled-connection-factory name="activemq-ra" entries="java:/JmsXA java:jboss/DefaultJMSConnectionFactory" connectors="in-vm" transaction="xa"/></server></subsystem>#g' /opt/eap/standalone/configuration/standalone-openshift.xml
${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/bin/configuration/setup.cli

#echo "Running secure-deployments : secure-deployments.cli "
#${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/bin/configuration/secure-deployments.cli

echo "Unzipping keycloak theme"
unzip -o -d ${JBOSS_HOME} /opt/tools/keycloak-theme/keycloak-theme.jar
cp ${JBOSS_HOME}/themes/mta/login/login_required.theme.properties ${JBOSS_HOME}/themes/mta/login/theme.properties

echo "Setting up keycloak server admin username/password"
${JBOSS_HOME}/bin/add-user-keycloak.sh --realm master --user admin --password password

echo "Setting up keycloak server mta default username/password"
${JBOSS_HOME}/bin/add-user-keycloak.sh --realm mta --user mta --password password --roles user

echo "Setting up JMS Password"
${JBOSS_HOME}/bin/add-user.sh -r ApplicationRealm -u jms-user -p gthudfal -g guest \
    -up ${JBOSS_HOME}/standalone/configuration/application-users.properties -gp \
    ${JBOSS_HOME}/standalone/configuration/application-roles.properties

# If there is no DB prefix mapping, then setup an internal H2 Instance
if [ -z ${DB_SERVICE_PREFIX_MAPPING+x} ]
then
    echo "Setting up embedded database, as the DB_SERVICE_PREFIX_MAPPING was not set"
    ${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/bin/configuration/db_h2.cli
fi

echo "Setting up as a master node"
${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/bin/configuration/master.cli

echo "Configuring keycloak and openshift layers"
sed -i -e 's#layers=keycloak#layers=keycloak,openshift#g' /opt/eap/modules/layers.conf

##sed -i -e 's#<protocol type="pbcast.GMS"/>##g' /opt/eap/standalone/configuration/standalone-openshift.xml