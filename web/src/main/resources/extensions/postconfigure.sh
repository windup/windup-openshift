#!/usr/bin/env bash
set -x
echo "Creating Windup Queues and Topics"
$JBOSS_HOME/bin/jboss-cli.sh --echo-command --file=$JBOSS_HOME/extensions/jms.cli
