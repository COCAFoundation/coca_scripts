#!/bin/bash


echo "********************************" >&2
echo "RUNNING DATABASE RESTORE.SH" >&2
echo "********************************" >&2

echo "Reading Configuration File" >&2
source config/script.cfg

## DESTINATION ENVIRONMENT VARIABLES
# SSH
destination_ssh_host=$dev_ssh_host
#DATABASE
destination_database_host=$dev_database_host
destination_database_db=$dev_database_db
destination_database_user=$dev_database_user
destination_database_password=$dev_database_password
# FTP
destination_ftp_host=$dev_ftp_host
destination_ftp_user=$dev_ftp_user
destination_ftp_password=$dev_ftp_password
destination_ftp_base_directory=$dev_ftp_base_directory
destination_ftp_base_path=$dev_ftp_base_path
destination_joomla_config_file=$dev_joomla_config_file

## SOURCE ENVIRONMENT VARIABLES
# SSH
source_ssh_host=$prod_ssh_host
# DATABASE
source_database_host=$prod_database_host
source_database_db=$prod_database_db
source_database_user=$prod_database_user
source_database_password=$prod_database_password
# FTP
source_ftp_host=$prod_ftp_host
source_ftp_user=$prod_ftp_user
source_ftp_password=$prod_ftp_password
source_ftp_base_directory=$prod_ftp_base_directory
source_ftp_base_path=$prod_ftp_base_path


echo "*Source: production" >&2
echo "*Destination Database: dev1" >&2

# PRODUCTION DATABASE BACKUP
echo "*Performing Backup of source database" >&2
mysqldump -h $source_database_host --user=$source_database_user --password=$source_database_password coca_prod > working/tmp_mysql_backup.sql


# CREATE DROP/TRUNCATE SCRIPTS
echo "*Creating Drop/Truncate Scripts for destination database" >&2
mysql -N -h $destination_database_host --database=$destination_database_db --user=$destination_database_user --password=$destination_database_password < scripts/mysql_create_truncate.sql > working/tmp_mysql_truncate.sql
mysql -N -h $destination_database_host --database=$destination_database_db --user=$destination_database_user --password=$destination_database_password < scripts/mysql_create_drop.sql > working/tmp_mysql_drop.sql

# RUN DROP/TRUNCATE SCRIPTS AND RESTORE DATABASE
echo "*Performing Restore" >&2
mysql -N -h $destination_database_host --database=$destination_database_db --user=$destination_database_user --password=$destination_database_password < working/tmp_mysql_truncate.sql
mysql -N -h $destination_database_host --database=$destination_database_db --user=$destination_database_user --password=$destination_database_password < working/tmp_mysql_drop.sql
mysql -N -h $destination_database_host --database=$destination_database_db --user=$destination_database_user --password=$destination_database_password < working/tmp_mysql_backup.sql

# REMOVE WORKING FILES
echo "*Removing Working Files" >&2
rm working/*
