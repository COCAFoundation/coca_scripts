#!/bin/bash

# DATABASE_RESTORE.SH SCRIPT
#
# Requirements:
#
#

echo "********************************" >&2
echo "RUNNING DATABASE RESTORE.SH" >&2
echo "********************************" >&2
echo ''
echo ''
echo "Determening Source and Destination Environment" >&2

runScript=true


case "$1" in
1)  echo "Reading Production Configuration File" >&2
    source config/prod-environment.cfg
    echo "Done!" >&2
    ;;
2)  echo "Reading Test Configuration File" >&2
    source config/test-environment.cfg
    echo "Done!" >&2
    ;;
3)  echo "Reading Dev Configuration File" >&2
    source config/dev-environment.cfg
    echo "Done!" >&2
    ;;
4)  echo "Reading Dev2 Configuration File" >&2
    source config/dev2-environment.cfg
    echo "Done!" >&2
    ;;
*) echo "$1 not recognized, cannot execute"
   runScript=false
   source_environment_name='Fail'
   ;;
esac

source_environment_name=$environment_name
## SOURCE ENVIRONMENT VARIABLES
# SSH
source_ssh_host=$ssh_host
# DATABASE
source_database_host=$database_host
source_database_db=$database_db
source_database_user=$database_user
source_database_password=$database_password
# FTP
source_ftp_host=$ftp_host
source_ftp_user=$ftp_user
source_ftp_password=$ftp_password
source_ftp_base_directory=$ftp_base_directory
source_ftp_base_path=$ftp_base_path


case "$2" in
1)  echo "Reading Production Configuration File" >&2
    source config/prod-environment.cfg
    echo "Done!" >&2
    ;;
2)  echo "Reading Test Configuration File" >&2
    source config/test-environment.cfg
    echo "Done!" >&2
    ;;
3)  echo "Reading Dev Configuration File" >&2
    source config/dev-environment.cfg
    echo "Done!" >&2
    ;;
4)  echo "Reading Dev2 Configuration File" >&2
    source config/dev2-environment.cfg
    echo "Done!" >&2
    ;;
*) echo "$2 not recognized, cannot execute"
   runScript=false
   source_environment_name='Fail'
   ;;
esac


destination_environment_name=$environment_name
## DESTINATION ENVIRONMENT VARIABLES
# SSH
destination_ssh_host=$ssh_host
#DATABASE
destination_database_host=$database_host
destination_database_db=$database_db
destination_database_user=$database_user
destination_database_password=$database_password
# FTP
destination_ftp_host=$ftp_host
destination_ftp_user=$ftp_user
destination_ftp_password=$ftp_password
destination_ftp_base_directory=$ftp_base_directory
destination_ftp_base_path=$ftp_base_path
destination_joomla_config_file=$joomla_config_file


if [ $1 = $2 ] ; then
    echo 'Site cannot restore to self!!!!!'
    echo '......canceling.'
    runScript=false
fi

if [ "$runScript" = true ] ; then

  echo ''
  echo ''
  echo '*************************************'
  echo 'Selected: ' $source_environment_name '->' $destination_environment_name
  echo '*************************************'
  echo ''
  echo ''

  # ADDED for OSX MYSQL Compatability
  export PATH=${PATH}:/usr/local/mysql/bin

  # PRODUCTION DATABASE BACKUP
  echo "*Performing Backup of source database" >&2
  mysqldump -h $source_database_host --user=$source_database_user --password=$source_database_password $source_database_db > working/tmp_mysql_backup.sql


  # CREATE DROP/TRUNCATE SCRIPTS
  echo "*Creating Drop/Truncate Scripts for destination database" >&2

  sed "s/placeHolder/$destination_database_db/g" scripts/mysql_create_truncate.sql > working/mysql_create_truncate.sql
  sed "s/placeHolder/$destination_database_db/g" scripts/mysql_create_drop.sql > working/mysql_create_drop.sql

  mysql -N -h $destination_database_host --database=$destination_database_db --user=$destination_database_user --password=$destination_database_password < working/mysql_create_truncate.sql > working/tmp_mysql_truncate.sql
  mysql -N -h $destination_database_host --database=$destination_database_db --user=$destination_database_user --password=$destination_database_password < working/mysql_create_drop.sql > working/tmp_mysql_drop.sql

  # RUN DROP/TRUNCATE SCRIPTS AND RESTORE DATABASE
  echo "*Performing Restore" >&2
  mysql -N -h $destination_database_host --database=$destination_database_db --user=$destination_database_user --password=$destination_database_password < working/tmp_mysql_truncate.sql
  mysql -N -h $destination_database_host --database=$destination_database_db --user=$destination_database_user --password=$destination_database_password < working/tmp_mysql_drop.sql
  mysql -N -h $destination_database_host --database=$destination_database_db --user=$destination_database_user --password=$destination_database_password < working/tmp_mysql_backup.sql

  # REMOVE WORKING FILES
  echo "*Removing Working Files" >&2
  rm working/*
fi

echo ''
echo ''
echo "********************************" >&2
echo "COMPLETED DATABASE_RESTORE.SH" >&2
echo "********************************" >&2
