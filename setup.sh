#!/bin/bash
#
# Setup script for efiboot-cli project
#

echo "Creating required directories..."
mkdir -p data/backup data/logs

echo "Setting permissions for directories..."
chmod 755 data data/backup data/logs

echo "Setting permissions for JSON backup files..."
if compgen -G "data/backup/*.json" > /dev/null; then
  chmod 644 data/backup/*.json
else
  echo "No JSON backup files found yet."
fi

echo "Setting execute permissions for scripts..."
chmod 755 efiboot-cli.sh lib/*.sh

echo "Setup completed successfully."

