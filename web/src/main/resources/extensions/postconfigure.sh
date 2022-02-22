#!/usr/bin/env bash
set -x
echo "Executing postconfigure.sh"
$JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/extensions/jms.cli

$JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/extensions/secure-deployments.cli
