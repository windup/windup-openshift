#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

export JAVA_OPTS="$JAVA_OPTS -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=512m"
export JAVA_OPTS="$JAVA_OPTS -Djboss.modules.system.pkgs=org.jboss.byteman"
export JAVA_OPTS="$JAVA_OPTS -Djboss.modules.settings.xml.url=file://$GALLEON_MAVEN_SETTINGS_XML"
export JAVA_OPTS="$JAVA_OPTS -Dkeycloak.migration.action=import -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=${JBOSS_HOME}/standalone/configuration/import-realm.json -Dkeycloak.migration.strategy=IGNORE_EXISTING"

export MAVEN_SETTINGS_PATH="$GALLEON_MAVEN_SETTINGS_XML"

echo 'echo "Installing PostgreSQL driver"' >> /opt/eap/bin/launch/launch.sh
echo "${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/driver/db_postgresql.cli" >> /opt/eap/bin/launch/launch.sh

echo 'echo "Installing Required Configuration"' >> /opt/eap/bin/launch/launch.sh
echo "source ${JBOSS_HOME}/bin/inject.sh" >> /opt/eap/bin/launch/launch.sh

/opt/eap/bin/openshift-launch.sh "$@"
