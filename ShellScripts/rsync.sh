#!/bin/bash

# Variables
VM_NAME="gsdcobmdb01"
DISK_DIR="/vmconfig/vms/${VM_NAME}"
BACKUP_ROOT="/vmconfig/backup"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_PATH="${BACKUP_ROOT}/${VM_NAME}_${TIMESTAMP}"
BACKUP_XML_PATH="${BACKUP_PATH}/${VM_NAME}.xml"
COMPRESSED_BACKUP_PATH="${BACKUP_ROOT}/${VM_NAME}_${TIMESTAMP}.tar.gz"

# Ensure backup directory exists
mkdir -p $BACKUP_PATH

# Backup each QCOW2 disk image
echo "Starting backup of QCOW2 disk images..."
for DISK_PATH in ${DISK_DIR}/*.qcow*; do
    DISK_NAME=$(basename $DISK_PATH)
    BACKUP_DISK_PATH="${BACKUP_PATH}/${DISK_NAME}"
    echo "Backing up $DISK_PATH to $BACKUP_DISK_PATH"
    rsync -avh --progress $DISK_PATH $BACKUP_DISK_PATH
done

# Backup VM configuration
echo "Backing up VM configuration to: $BACKUP_XML_PATH"
virsh dumpxml $VM_NAME > $BACKUP_XML_PATH

# Compress the backup directory
echo "Compressing backup files into: $COMPRESSED_BACKUP_PATH"
tar -czvf $COMPRESSED_BACKUP_PATH -C $BACKUP_ROOT "$(basename $BACKUP_PATH)"

# Optionally remove uncompressed files if needed
rm -rf $BACKUP_PATH

echo "Backup completed."
