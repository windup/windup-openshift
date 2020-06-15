#!/bin/bash

PING_DIR=/opt/mta-cli/ping
SUFFIX=`date +%s%N`
PING_FILE=$PING_DIR/ping.$SUFFIX
PONG_FILE=$PING_DIR/pong.$SUFFIX

if [[ ! -d $PING_DIR ]] ; then
#    echo "File \"$PING_DIR\" is not there, waiting a few seconds first."
    sleep 20
fi

if [[ ! -f $PING_FILE ]] ; then
    touch $PING_FILE
    sleep 5
fi

if [[ ! -f $PONG_FILE ]] ; then
    echo "File \"$PONG_FILE\" is not there, aborting."
    exit 1
fi
rm $PONG_FILE
