#!/bin/bash

PING_DIR=/opt/rhamt-cli/ping
PING_FILE=$PING_DIR/ping
PONG_FILE=$PING_DIR/pong

if [[ ! -d $PING_DIR ]] ; then
    echo 'File "$PING_DIR" is not there, waiting a few seconds first.'
    sleep 10
fi

touch $PING_DIR/ping
sleep 2

if [[ ! -f $PONG_FILE ]] ; then
    echo 'File "$PONG_FILE" is not there, aborting.'
    exit 1
fi
