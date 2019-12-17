#!/usr/bin/env bash
echo "Installing PostgreSQL driver"
${JBOSS_HOME}/bin/jboss-cli.sh --echo-command --file=./db_postgresql.cli

