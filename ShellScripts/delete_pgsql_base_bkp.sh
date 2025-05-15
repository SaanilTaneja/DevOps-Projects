#!/bin/bash

# Directory where the backup folders are located
BACKUP_DIR="/backup/pgsql_base_bkp"

# Ensure the directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Directory $BACKUP_DIR does not exist."
    exit 1
fi

# Find and delete directories older than 3 days (excluding the base directory)
find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +3 -exec rm -rf {} \;

# Check if the operation was successful
if [ $? -eq 0 ]; then
    echo "Old backup directories deleted successfully."
else
    echo "An error occurred while deleting old backup directories."
fi
