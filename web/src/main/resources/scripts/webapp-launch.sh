#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

#export JAVAzSi,_OPTS="$JAVA_OPTS -Djboss.modules.system.pkgs=org.jboss.byteman "
#export JAVA_OPTS="$JAVA_OPTS -Dsun.util.logging.disableCallerCheck=true -Djboss.modules.settings.xml.url=file://$GALLEON_MAVEN_SETTINGS_XML"

#export MAVEN_SETTINGS_PATH="$GALLEON_MAVEN_SETTINGS_XML"

echo 'echo "Installing PostgreSQL driver"' >> /opt/eap/bin/launch/launch.sh
echo "${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=/extensions/db_postgresql.cli" >> /opt/eap/bin/launch/launch.sh
echo "source ${JBOSS_HOME}/bin/inject.sh" >> /opt/eap/bin/launch/launch.sh

# Inject our own changes to the launch script (remove the logging changes that break forge integration)
#sed -i -e 's#-Xbootclasspath/p:${JBOSS_MODULES_JAR}:${JBOSS_LOGMANAGER_JAR}:${JBOSS_JSON_JAR}:${JBOSS_JSON_API_JAR}:${WILDFLY_COMMON_JAR}#-Xbootclasspath/p:${JBOSS_LOGMANAGER_JAR}:${JBOSS_JSON_JAR}:${WILDFLY_COMMON_JAR}#g' /opt/eap/bin/standalone.conf
#sed -i -e 's#-javaagent:$JBOSS_HOME/jolokia.jar=port=8778,protocol=https,caCert=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt,clientPrincipal=cn=system:master-proxy,useSslClientAuthentication=true,extraClientCheck=true,host=0.0.0.0,discoveryEnabled=false##g' /opt/eap/bin/standalone.conf
#sed -i -e 's#MaxMetaspaceSize=256m#MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=512m#g' /opt/eap/bin/standalone.conf

# Remove the jboss logging package from system packages
#sed -i -e 's#JBOSS_MODULES_SYSTEM_PKGS="jdk.nashorn.api,com.sun.crypto.provider"#JBOSS_MODULES_SYSTEM_PKGS="com.sun.crypto.provider"#g' /opt/eap/bin/launch/jboss_modules_system_pkgs.sh

# Remove line containing "jboss_modules_system_pkgs" - This is so that we can insert a new execution that runs a CLI script on startup
#cp /opt/eap/bin/openshift-launch.sh /opt/eap/bin/openshift-launch.sh.orig
#cat /opt/eap/bin/openshift-launch.sh.orig | grep -v jboss_modules_system_pkgs > /opt/eap/bin/openshift-launch.sh

#sed -i -e 's#$JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 0.0.0.0 -Djboss.server.data.dir=${instanceDir} -Dwildfly.statistics-enabled=true#executeEAPServer#g' /opt/eap/bin/openshift-launch.sh
#sed -i '2 a function executeEAPServer() {' /opt/eap/bin/openshift-launch.sh
#sed -i '3 a   source ${JBOSS_HOME}/bin/inject.sh ' /opt/eap/bin/openshift-launch.sh
#sed -i '4 a   $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 0.0.0.0 -Djboss.server.data.dir=${instanceDir} -Dwildfly.statistics-enabled=true' /opt/eap/bin/openshift-launch.sh
#sed -i '5 a }' /opt/eap/bin/openshift-launch.sh

/opt/eap/bin/openshift-launch.sh "$@"
