#!/bin/bash
# config.sh — constants and paths

# Path to efibootmgr binary
EFIBOOTMGR="/usr/sbin/efibootmgr"

# Version of efiboot-cli
EFIBOOT_CLI_VERSION="0.1.0"

# Data directories
DATA_DIR="./data"
BACKUP_DIR="$DATA_DIR/backup"
LOGS_DIR="$DATA_DIR/logs"

# Export default file
EXPORT_FILE="$BACKUP_DIR/bootentries.json"

