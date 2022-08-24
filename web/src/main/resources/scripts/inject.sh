#!/usr/bin/env bash

echo "Installing keycloak client adapters"
unzip -o -d ${JBOSS_HOME} ${JBOSS_HOME}/tools/keycloak-client-overlay/keycloak-wildfly-adapter-dist-*.zip
sed -i 's#embed-server --server-config=${server.config:standalone.xml}#embed-server --server-config=${server.config:standalone-openshift.xml}#g' ${JBOSS_HOME}/bin/adapter-install-offline.cli
${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/bin/adapter-install-offline.cli

echo "Running local CLI script for configuring logging, queues, and keycloak client realm"
${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/utils/configuration/setup.cli

if [[ -z "${SSO_AUTH_SERVER_URL}" ]]; then
  echo "Running unsecure-deployments : unsecure-deployments.cli"
  ${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/utils/configuration/unsecure-deployments.cli
else
  echo "Running secure-deployments : secure-deployments.cli"
  ${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/utils/configuration/secure-deployments.cli
fi

echo "Setting up JMS Password"
${JBOSS_HOME}/bin/add-user.sh -r ApplicationRealm -u jms-user -p gthudfal -g guest \
    -up ${JBOSS_HOME}/standalone/configuration/application-users.properties -gp \
    ${JBOSS_HOME}/standalone/configuration/application-roles.properties

# If there is no DB prefix mapping, then setup an internal H2 Instance
if [ -z ${DB_SERVICE_PREFIX_MAPPING+x} ]
then
    echo "Setting up embedded database, as the DB_SERVICE_PREFIX_MAPPING was not set"
    ${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/utils/configuration/db_h2.cli
fi

echo "Setting up as a master node"
${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/utils/configuration/master.cli
