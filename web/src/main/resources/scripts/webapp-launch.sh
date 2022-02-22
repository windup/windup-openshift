#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

export JAVA_OPTS="$JAVA_OPTS -Djboss.modules.system.pkgs=org.jboss.byteman "
export JAVA_OPTS="$JAVA_OPTS -Djboss.modules.settings.xml.url=file://$GALLEON_MAVEN_SETTINGS_XML"
export JAVA_OPTS="$JAVA_OPTS -Dkeycloak.migration.action=import -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=${JBOSS_HOME}/standalone/configuration/import-realm.json -Dkeycloak.migration.strategy=IGNORE_EXISTING"

export MAVEN_SETTINGS_PATH="$GALLEON_MAVEN_SETTINGS_XML"

echo 'echo "Installing PostgreSQL driver"' >> /opt/eap/bin/launch/launch.sh
echo "${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=${JBOSS_HOME}/driver/db_postgresql.cli" >> /opt/eap/bin/launch/launch.sh

echo 'echo "Installing Required Configuration"' >> /opt/eap/bin/launch/launch.sh
echo "source ${JBOSS_HOME}/bin/inject.sh" >> /opt/eap/bin/launch/launch.sh

# Remove the jboss logging package from system packages
sed -i -e 's#JBOSS_MODULES_SYSTEM_PKGS="jdk.nashorn.api,com.sun.crypto.provider"#JBOSS_MODULES_SYSTEM_PKGS="com.sun.crypto.provider"#g' /opt/eap/bin/launch/jboss_modules_system_pkgs.sh

/opt/eap/bin/openshift-launch.sh "$@"
