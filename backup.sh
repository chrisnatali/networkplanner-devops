#!/bin/bash

# Load Config
SCRIPTPATH=$(cd ${0%/*} && pwd -P)
source $SCRIPTPATH/backup.conf

echo "Starting backup for `date +\%Y-\%m-\%d`"

# Setup backup dir
BACKUP_DIR=${BACKUP_DIR%/} #remove xtra / if there
THIS_BACKUP_DIR=$BACKUP_DIR/`date +\%Y-\%m-\%d`
if ! mkdir -p $THIS_BACKUP_DIR
then
    echo "Cannot create backup directory: $THIS_BACKUP_DIR"
    exit 1
fi

echo "Creating backup of $DATABASE..."

DUMP_CMD="pg_dump -Fp $DATABASE"
if [ -n $DATABASE_USER ]
then
    DUMP_CMD="$DUMP_CMD -U $DATABASE_USER"
fi


$DUMP_CMD | gzip > $THIS_BACKUP_DIR/$DATABASE.sql.gz.in_progress
if [ 0 -ne $PIPESTATUS ]
then
    echo "Error creating backup of $DATABASE"
    rm -rf $THIS_BACKUP_DIR #rm dir so only successful backup dirs exist
    exit 1
else
    mv $THIS_BACKUP_DIR/$DATABASE.sql.gz.in_progress $THIS_BACKUP_DIR/$DATABASE.sql.gz
fi

echo "Database backup of $DATABASE complete"

echo "Creating backup of data directory $DATA_DIR..."

if ! tar -zcf $THIS_BACKUP_DIR/files.tar -C $DATA_DIR production
then
    echo "Error creating backup of $DATA_DIR"
    rm -rf $THIS_BACKUP_DIR #rm dir so only successful backup dirs exist
    exit 1
fi

echo "Backup of $DATA_DIR complete"

echo "Removing backups other than the last $NUM_BACKUPS..."
BACKUP_CT=`find $BACKUP_DIR -maxdepth 1 -name '*-*-*' | wc -l`
if [ $BACKUP_CT -gt $NUM_BACKUPS ]
then
    find $BACKUP_DIR -maxdepth 1 -name '*-*-*' | sort | head -n -$NUM_BACKUPS | xargs rm -rf
    if [ 0 -ne $PIPESTATUS ]
    then
        echo "Failed to remove backups"
        exit 1
    fi
fi

# Sync with S3
echo "Syncing backups with $S3_BUCKET..."

if ! s3cmd --delete-removed sync $BACKUP_DIR $S3_BUCKET
then
    echo "Failed to sync with S3"
    exit 1
fi

echo "Backup finished successfully"

