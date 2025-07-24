#!/bin/bash
#
# Clears all log files in ./data/logs/
#

LOGS_DIR="./data/logs"

if [[ -d "$LOGS_DIR" ]]; then
    rm -f "$LOGS_DIR"/*
    echo "All logs cleared from: $LOGS_DIR"
else
    echo "Logs directory does not exist: $LOGS_DIR"
fi

