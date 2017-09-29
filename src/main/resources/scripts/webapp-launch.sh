#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

# Inject our own changes to the launch script

# Run CLI script in offline mode

sed -i -e 's#-Xbootclasspath/p:${JBOSS_MODULES_JAR}:${JBOSS_LOGMANAGER_JAR}:${JBOSS_LOGMANAGER_EXT_JAR}##g' /opt/eap/bin/standalone.conf
sed -i -e 's#-Djava.util.logging.manager=org.jboss.logmanager.LogManager##g' /opt/eap/bin/standalone.conf
sed -i -e 's#-javaagent:$JBOSS_HOME/jolokia.jar=port=8778,protocol=https,caCert=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt,clientPrincipal=cn=system:master-proxy,useSslClientAuthentication=true,extraClientCheck=true,host=0.0.0.0,discoveryEnabled=false##g' /opt/eap/bin/standalone.conf

# Remove line containing "standalone.sh" - This is so that we can insert a new execution that runs a CLI script on startup
cp /opt/eap/bin/openshift-launch.sh /opt/eap/bin/openshift-launch.sh.orig
cat /opt/eap/bin/openshift-launch.sh.orig |grep -v standalone.sh | grep -v jboss_modules_system_pkgs > /opt/eap/bin/openshift-launch.sh

echo 'source ${JBOSS_HOME}/bin/inject.sh' >> /opt/eap/bin/openshift-launch.sh

# Add updated "standalone.sh"
echo 'exec $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 $JBOSS_HA_ARGS ${JBOSS_MESSAGING_ARGS}' >> /opt/eap/bin/openshift-launch.sh

JBOSS_MODULES_SYSTEM_PKGS=org.jboss.byteman ./openshift-launch.sh "$@"
