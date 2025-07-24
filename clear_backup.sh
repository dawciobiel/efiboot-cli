#!/bin/bash
#
# Clears the backup JSON file of EFI boot entries
#

BACKUP_FILE="./data/backup/bootentries.json"

if [[ -f "$BACKUP_FILE" ]]; then
    > "$BACKUP_FILE"  # truncate file
    echo "Backup file cleared: $BACKUP_FILE"
else
    echo "Backup file does not exist: $BACKUP_FILE"
fi

