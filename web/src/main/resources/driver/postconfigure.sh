#!/usr/bin/env bash
echo "Installing PostgreSQL driver"
${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=/opt/eap/extensions/db_postgresql.cli

