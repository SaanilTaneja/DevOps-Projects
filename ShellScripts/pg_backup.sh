#!/bin/bash

# Configuration
HOST="172.18.103.152"   # IP or hostname for both master and replica (adjust as needed)
PG_PORT=5432
PG_USER_REPLICATOR="replicator"    # User for pg_basebackup
PG_PASSWORD_REPLICATOR="replicator"  # Password for pg_basebackup
PG_USER_POSTGRES="postgres"       # Superuser for pg_dumpall
PG_PASSWORD_POSTGRES="postgres"  # Password for pg_dumpall
BACKUP_DIR_BASE="/backup/pgsql_base_bkp"  # Directory for base backups
BACKUP_DIR_DUMP="/backup/pgsql_dumpall_bkp"   # Directory for dumpall backup
DATE=$(date +%Y%m%d_%H%M%S)

# Patroni API URL for checking the role
PATRONI_API_URL="http://$HOST:8008"  # Adjust the port if necessary

# Check the role of the current node (leader/master or replica)
role=$(curl -s $PATRONI_API_URL/patroni | jq -r .role)

# Set the password for PostgreSQL connection for base backups
export PGPASSWORD=$PG_PASSWORD_REPLICATOR

# Ensure the backup directories exist
mkdir -p $BACKUP_DIR_BASE
mkdir -p $BACKUP_DIR_DUMP

if [ "$role" == "leader" ] || [ "$role" == "master" ]; then
  echo "Node is the master, performing pg_basebackup and pg_dumpall..."

  # Perform the backup using pg_basebackup in tar mode with compression
  pg_basebackup -h $HOST -p $PG_PORT -U $PG_USER_REPLICATOR -D $BACKUP_DIR_BASE/$DATE -Ft -Xs -P -R -z

  # Check if the base backup was successful
  if [ $? -eq 0 ]; then
    echo "pg_basebackup completed successfully at $BACKUP_DIR_BASE/$DATE"
  else
    echo "pg_basebackup failed!"
    exit 1
  fi

  # Set the password for PostgreSQL connection for pg_dumpall
  export PGPASSWORD=$PG_PASSWORD_POSTGRES

  # Perform the backup using pg_dumpall
  pg_dumpall -h $HOST -p $PG_PORT -U $PG_USER_POSTGRES > $BACKUP_DIR_DUMP/pgsql_backup_$DATE.sql

  # Check if the pg_dumpall was successful
  if [ $? -eq 0 ]; then
    echo "pg_dumpall completed successfully at $BACKUP_DIR_DUMP/pgsql_backup_$DATE.sql"
  else
    echo "pg_dumpall failed!"
    exit 1
  fi

  # Optionally, compress the pg_dumpall backup to save space
  gzip $BACKUP_DIR_DUMP/pgsql_backup_$DATE.sql

elif [ "$role" == "replica" ]; then
  echo "Node is a replica, performing pg_basebackup..."

  # Perform the backup using pg_basebackup in tar mode with compression
  pg_basebackup -h $HOST -p $PG_PORT -U $PG_USER_REPLICATOR -D $BACKUP_DIR_BASE/$DATE -Ft -Xs -P -R -z

  # Check if the base backup was successful
  if [ $? -eq 0 ]; then
    echo "pg_basebackup completed successfully at $BACKUP_DIR_BASE/$DATE"
  else
    echo "pg_basebackup failed!"
    exit 1
  fi

else
  echo "Node is neither a master nor a replica, backup aborted."
  exit 1
fi

# Unset the password variable after the backup is done
unset PGPASSWORD

# Optionally, you can remove old backups to save space
# Uncomment and adjust the following lines to delete backups older than 7 days
# find $BACKUP_DIR_BASE -type d -mtime +7 -exec rm -rf {} \;
# find $BACKUP_DIR_DUMP -type f -name "*.gz" -mtime +7 -exec rm -f {} \;

echo "Backup process completed."
