# drahoslavzan/mariadb-backup-s3

Docker image which dumps all MariaDB databases to AWS S3.

This image will run **mysqldump** on a selected host and put the result into an S3 bucket.

## Environment variables

|           VAR           |          DESCRIPTION         |
|-------------------------|------------------------------|
|  CRON_SCHEDULE          | Cron schedule, leave empty to disable cron job. |
|  BACKUP_FILE            | Name of the backup file, e.g. **matomodb** |
|  MYSQL_HOST             | DB host name |
|  MYSQL_USER             | DB user, e.g. **root** |
|  MYSQL_PASS             | DB password |
|  AWS_ACCESS_KEY_ID      | AWS access key ID |
|  AWS_SECRET_ACCESS_KEY  | AWS secret access key |
|  AWS_DEFAULT_REGION     | AWS region, e.g. **us-east-2** |
|  AWS_BUCKET_DIR         | AWS bucker directory, e.g. **s3://myawsomebucket/backup** |

## Examples

The example below will backup matomo database every day at 1 am. It will create **/opt/backup/matomodb.bz2"** file locally and upload it to S3 folder named **/backup** inside the **myawesomebucket** bucket.

```yml
version: '3'

services:
  matomodb:
    image: bitnami/mariadb:10.5
    container_name: matomodb
    restart: always
    networks:
      - matomodb
    volumes:
      - /opt/matomo/db:/bitnami
    environment:
      - MARIADB_EXTRA_FLAGS=--max_allowed_packet=64MB
      - MARIADB_ROOT_PASSWORD=<MYSQL_ROOT_PASS>

  matomodb-backup:
      image: drahoslavzan/mariadb-backup-s3:latest
      container_name: matomodb-backup
      restart: always
      volumes:
        - /opt/backup:/backup
      networks:
        - matomodb
      environment:
        - CRON_SCHEDULE=0 1 * * *
        - BACKUP_FILE=matomodb
        - MYSQL_HOST=matomodb
        - MYSQL_USER=root
        - MYSQL_PASS=<MYSQL_ROOT_PASS>
        - AWS_ACCESS_KEY_ID=<AWS_KEY>
        - AWS_SECRET_ACCESS_KEY=<AWS_SECRET>
        - AWS_DEFAULT_REGION=us-east-2
        - AWS_BUCKET_DIR=s3://myawesomebucket/backup

networks:
  matomodb:
```

## AWS S3 Configuration

1. Create AWS account.
2. Create S3 bucker in a region you want, choose a unique bucket name, e.g. **myawesomebucket**. You can leave all options in their default value, make sure you have enabled private access only.
3. Create a folder inside the bucket called **backup**.
4. Create the **backup** user with programmatic access.
5. Create a new policy called **BackupAccess** and inside the json editor put the file below (do not forget to change **myawesomebucket** to your bucket name)

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::myawesomebucket"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::myawesomebucket/backup/*"
        }
    ]
}
```
6. Assign **BackupAccess** policy to the **backup** user.
7. Provide the *bucket region* and the **backup** user *access and secret keys* to the configuration (env variables).
8. You are all set!
