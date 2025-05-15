#!/bin/bash

# Directory where the backup files are located
BACKUP_DIR="/backup/pgsql_dumpall_bkp"

# Ensure the directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Directory $BACKUP_DIR does not exist."
    exit 1
fi

# Find and delete files older than 3 days
find "$BACKUP_DIR" -type f -name "pgsql_backup_*.sql.gz" -mtime +3 -exec rm -f {} \;

# Check if the operation was successful
if [ $? -eq 0 ]; then
    echo "Old PostgreSQL backup files deleted successfully."
else
    echo "An error occurred while deleting old PostgreSQL backup files."
fi
