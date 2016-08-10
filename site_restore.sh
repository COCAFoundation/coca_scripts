#!/bin/bash

# SITE_RESTORE.SH SCRIPT
#
# Requirements:
# - dev configuration.php
#

echo "********************************" >&2
echo "RUNNING SITE RESTORE.SH" >&2
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




# ZIP UP Source
echo "*Zipping up Source Site" >&2
ssh $source_ftp_user@$source_ssh_host "zip -r -q -X site-backup.zip $source_ftp_base_directory"

# DOWNLOAD FILE THEN REMOVE ZIP FROM PRODUCTION
echo "*Downloading source zip file" >&2
scp $source_ftp_user@$source_ssh_host:site-backup.zip site-backup.zip
ssh $source_ftp_user@$source_ssh_host "rm -r site-backup.zip"

# UPLOAD FILE TO DEV
echo "*uploading source zip file to destination" >&2
scp site-backup.zip $destination_ftp_user@$destination_ssh_host:site-backup.zip

# UNZIP ZIP FILE TO UNZIP FOLDER AND REMOVE ZIP FILE
echo "unzipping zip file" >&2
ssh $destination_ftp_user@$destination_ssh_host "unzip -q site-backup.zip -d unzip"
ssh $destination_ftp_user@$destination_ssh_host "rm  site-backup.zip"

# REMOVE OLD DEV DIRECTORY
echo "deleting old destination site" >&2
ssh $destination_ftp_user@$destination_ssh_host "rm -r dev"

# CLEAR OUT DEV
echo "cleaning up temporary directories" >&2
ssh $destination_ftp_user@$destination_ssh_host "mv unzip/$prod_ftp_base_directory dev"

# REMOVE WORKING DIRECTORIES
ssh $destination_ftp_user@$destination_ssh_host "rm -r unzip"
rm site-backup.zip

# UPDATE CONFIGURATION.PHP
echo "Updating destination Joomla configuration file" >&2
ssh $destination_ftp_user@$destination_ssh_host "rm $destination_ftp_base_directory/configuration.php"
scp $destination_joomla_config_file $destination_ftp_user@$destination_ssh_host:$destination_ftp_base_directory/configuration.php
