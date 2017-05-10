#!/usr/bin/env bash

export HOME=/root

# Create directory for filesync
if [ ! -d "$UNISON_DIR" ]; then
    echo "Creating $UNISON_DIR directory for sync..."
    mkdir -p $UNISON_DIR >> /dev/null 2>&1
fi

# Start process on path which we want to sync
cd $UNISON_DIR

# Gracefully stop the process on 'docker stop'
trap 'kill -TERM $PID' TERM INT

# Run unison server
exec unison -socket 5000 >>/var/log/unison.log 2>&1

# Wait until the process is stopped
PID=$!
wait $PID
trap - TERM INT
wait $PID
EXIT_STATUS=$?
