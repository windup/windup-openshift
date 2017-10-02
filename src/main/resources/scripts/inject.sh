mkdir -p ${JBOSS_HOME}/standalone/log

echo "Installing keycloak server"
unzip -o -d ${JBOSS_HOME} /opt/tools/keycloak-server-overlay/keycloak-server-overlay-*.zip
sed -i 's#embed-server --server-config=standalone.xml#embed-server --server-config=standalone-openshift.xml#g' ${JBOSS_HOME}/bin/keycloak-install.cli

echo "Running keycloak server CLI script"
${JBOSS_HOME}/bin/jboss-cli.sh --file=${JBOSS_HOME}/bin/keycloak-install.cli

echo "Installing keycloak client adapters"
unzip -o -d /opt/eap/ /opt/tools/keycloak-client-overlay/keycloak-wildfly-adapter-dist-2.5.5.Final.zip
sed -i 's#embed-server --server-config=standalone.xml#embed-server --server-config=standalone-openshift.xml#g' ${JBOSS_HOME}/bin/adapter-install-offline.cli

echo "Running keycloak client adapter cli script"
${JBOSS_HOME}/bin/jboss-cli.sh --file=${JBOSS_HOME}/bin/adapter-install-offline.cli

echo "Running local CLI script for configuring logging, queues, and keycloak client realm"
# Run our CLI script (logging and keycloak configuration)
${JBOSS_HOME}/bin/jboss-cli.sh --file=${JBOSS_HOME}/standalone/configuration/setup.cli

echo "Setting up keycloak server admin username/password"
java -jar /opt/tools/keycloak-tool/keycloak-tool.jar initialize-keycloak \
    --username admin \
    --password password \
    --file \
    ${JBOSS_HOME}/standalone/configuration/keycloak-add-user.json
