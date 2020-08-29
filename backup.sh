#!/usr/bin/bash
set -e

source /app/.env

MYSQL_HOST=${MYSQL_HOST:?"MYSQL_HOST is required"}
MYSQL_USER=${MYSQL_USER:?"MYSQL_USER is required"}
MYSQL_PASS=${MYSQL_PASS:?"MYSQL_PASS is required"}

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"AWS_ACCESS_KEY_ID is required"}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"AWS_SECRET_ACCESS_KEY is required"}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:?"AWS_DEFAULT_REGION is required"}
AWS_BUCKET_DIR=${AWS_BUCKET_DIR:?"AWS_BUCKET_DIR is required"}
BACKUP_FILE=${BACKUP_FILE:?"BACKUP_FILE is required"}

fname="/backup/$BACKUP_FILE.bz2"

echo "Dumping MYSQL database..."
mysqldump -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASS" --single-transaction --routines --triggers --all-databases | bzip2 - > "$fname"

echo "Uploading to S3..."
aws s3 cp "$fname" "$AWS_BUCKET_DIR/"

echo "Done"