mkdir -p ${JBOSS_HOME}/standalone/log

# Run our CLI script
${JBOSS_HOME}/bin/jboss-cli.sh --file=${JBOSS_HOME}/standalone/configuration/setup.cli
