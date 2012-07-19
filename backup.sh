#!/bin/bash

# Load Config
SCRIPTPATH=$(cd ${0%/*} && pwd -P)
source $SCRIPTPATH/backup.conf

# Setup backup dir
BACKUP_DIR=${BACKUP_DIR%/} #remove xtra / if there
THIS_BACKUP_DIR=$BACKUP_DIR/`date +\%Y-\%m-\%d`
if ! mkdir -p $THIS_BACKUP_DIR; then
    echo "Cannot create backup directory: $THIS_BACKUP_DIR"
    exit 1
fi

echo "Creating backup of $DATABASE..."

DUMP_CMD="pg_dump -Fp $DATABASE"
if [ -n $DATABASE_USER ]; then
    DUMP_CMD="$DUMP_CMD -U $DATABASE_USER"
fi


if ! $DUMP_CMD | gzip > $THIS_BACKUP_DIR/$DATABASE.sql.gz.in_progress; then
    echo "Error creating backup of $DATABASE"
    exit 1
else
    mv $THIS_BACKUP_DIR/$DATABASE.sql.gz.in_progress $THIS_BACKUP_DIR/$DATABASE.sql.gz
fi

echo "Database backup of $DATABASE complete"

echo "Creating backup of data directory $DATA_DIR..."

if ! tar -zcf $THIS_BACKUP_DIR/files.tar -C $DATA_DIR production; then
    echo "Error creating backup of $DATA_DIR"
    exit 1
fi

echo "Backup of $DATA_DIR complete"

echo "Removing backups older than $DAYS_TO_KEEP days..."
if ! find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name '*-*-*'| xargs rm -rf; then
    echo "Failed to remove backups"
    exit 1
fi

echo "Backup finished successfully"

