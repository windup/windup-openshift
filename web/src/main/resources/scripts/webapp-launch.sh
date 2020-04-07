#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

# activar las 2 siguientes para que no se queje que no encuentra logmanager
#LogManager java options
export JAVA_OPTS="$JAVA_OPTS -Djboss.modules.system.pkgs=org.jboss.byteman,org.jboss.logmanager "
export JAVA_OPTS="$JAVA_OPTS -Dsun.util.logging.disableCallerCheck=true -Djboss.modules.settings.xml.url=file://$GALLEON_MAVEN_SETTINGS_XML"

export MAVEN_SETTINGS_PATH="$GALLEON_MAVEN_SETTINGS_XML"

#echo "export JAVA_OPTS=-Djboss.modules.settings.xml.url=file://$GALLEON_MAVEN_SETTINGS_XML" >> /opt/eap/bin/launch/launch.sh
echo 'echo "Installing PostgreSQL driver"' >> /opt/eap/bin/launch/launch.sh
echo "${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=/opt/eap/extensions/db_postgresql.cli" >> /opt/eap/bin/launch/launch.sh

# desactivar la siguiente para que no de se queje de aesh
#echo "unset JAVA_OPTS" >> /opt/eap/bin/launch/launch.sh

# Inject our own changes to the launch script (remove the logging changes that break forge integration)
#sed -i -e 's#-Xbootclasspath/p:${JBOSS_MODULES_JAR}:${JBOSS_LOGMANAGER_JAR}:${JBOSS_JSON_JAR}:${JBOSS_JSON_API_JAR}:${WILDFLY_COMMON_JAR}##g' /opt/eap/bin/standalone.conf
#sed -i -e 's#-Djava.util.logging.manager=org.jboss.logmanager.LogManager##g' /opt/eap/bin/standalone.conf
sed -i -e 's#-javaagent:$JBOSS_HOME/jolokia.jar=port=8778,protocol=https,caCert=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt,clientPrincipal=cn=system:master-proxy,useSslClientAuthentication=true,extraClientCheck=true,host=0.0.0.0,discoveryEnabled=false##g' /opt/eap/bin/standalone.conf
sed -i -e 's#MaxMetaspaceSize=256m#MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=512m#g' /opt/eap/bin/standalone.conf

# Remove the jboss logging package from system packages
sed -i -e 's#JBOSS_MODULES_SYSTEM_PKGS="org.jboss.logmanager,jdk.nashorn.api"##g' /opt/eap/bin/launch/jboss_modules_system_pkgs.sh

# This one works with the eap 7.1 image
sed -i -e 's#JBOSS_MODULES_SYSTEM_PKGS="org.jboss.logmanager,jdk.nashorn.api,com.sun.crypto.provider"#JBOSS_MODULES_SYSTEM_PKGS="com.sun.crypto.provider"#g' /opt/eap/bin/launch/jboss_modules_system_pkgs.sh

# Remove line containing "standalone.sh" - This is so that we can insert a new execution that runs a CLI script on startup
cp /opt/eap/bin/openshift-launch.sh /opt/eap/bin/openshift-launch.sh.orig
cat /opt/eap/bin/openshift-launch.sh.orig | grep -v jboss_modules_system_pkgs > /opt/eap/bin/openshift-launch.sh

sed -i -e 's#$JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 0.0.0.0 -Djboss.server.data.dir="$instanceDir" -Dwildfly.statistics-enabled=true ${JAVA_PROXY_OPTIONS} ${JBOSS_HA_ARGS} ${JBOSS_MESSAGING_ARGS} &#executeEAPServer#g' /opt/eap/bin/openshift-launch.sh
sed -i '2 a function executeEAPServer() {' /opt/eap/bin/openshift-launch.sh
sed -i '3 a   source ${JBOSS_HOME}/bin/inject.sh ' /opt/eap/bin/openshift-launch.sh
sed -i '4 a   echo "executing standalone.sh -Dkeycloak.migration...."' /opt/eap/bin/openshift-launch.sh
sed -i '5 a   exec $JBOSS_HOME/bin/standalone.sh -Dkeycloak.migration.action=import -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=${JBOSS_HOME}/standalone/configuration/import-realm.json -Dkeycloak.migration.strategy=IGNORE_EXISTING -c standalone-openshift.xml -bmanagement 0.0.0.0 $JBOSS_HA_ARGS ${JBOSS_MESSAGING_ARGS}' /opt/eap/bin/openshift-launch.sh
sed -i '6 a   echo "finished executing standalone.sh -Dkeycloak.migration...."' /opt/eap/bin/openshift-launch.sh
sed -i '7 a }' /opt/eap/bin/openshift-launch.sh

sed -i -e 's#org.jboss.as.standalone#-logmodule org.jboss.logmanager org.jboss.as.standalone#g' /opt/eap/bin/standalone.sh

bash -x /opt/eap/bin/openshift-launch.sh "$@"
