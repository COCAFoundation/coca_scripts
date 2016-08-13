#!/bin/bash


runScript=true


echo ''
echo ''
echo 'Running restore_all.sh'
echo ''
echo ''


echo 'Please select source environment'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '1: Production'
echo '2: Test'
echo '3: Dev'
echo '4: Dev2'
read -p "Enter number (default = 1: Production): " sourceEnvironment

echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
case "$sourceEnvironment" in
1)  echo "Seleted Production as Source"
    sourceEnvironmentName='Production'
    ;;
2)  echo  "Seleted Test as Source"
    sourceEnvironmentName='Test'
    ;;
3)  echo  "Seleted Dev as Source"
    sourceEnvironmentName='Dev'
    ;;
4) echo  "Seleted Dev2 as Source"
   sourceEnvironmentName='Dev2'
   ;;
*) echo "$sourceEnvironment not recognized, defaulted to Production as Source Environment"
   sourceEnvironment=1
   sourceEnvironmentName='Production'
   ;;
esac

echo ''
echo ''


echo 'Please select Destination environment'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '1: Production'
echo '2: Test'
echo '3: Dev'
echo '4: Dev2'
read -p "Enter number (default = 3: Dev): " destinationEnvironment

echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
case "$destinationEnvironment" in
1)  echo "Seleted Production as Destination"
    destinationEnvironmentName="Production"
    ;;
2)  echo  "Seleted Test as Destination"
    destinationEnvironmentName="Test"
    ;;
3)  echo  "Seleted Dev as Destination"
    destinationEnvironmentName="Dev"
    ;;
4) echo  "Seleted Dev2 as Destination"
    destinationEnvironmentName="Dev2"
   ;;
*) echo "$destinationEnvironment not recognized, defaulted to Dev as Destination"
  destinationEnvironment=3
  destinationEnvironmentName="Dev"
   ;;
esac

echo ''
echo ''
echo '*************************************'
echo 'Selected: ' $sourceEnvironmentName '->' $destinationEnvironmentName
echo '*************************************'


if [ $sourceEnvironment = $destinationEnvironment ] ; then
    echo 'Site cannot restore to self!!!!!'
    echo '......canceling.'
    runScript=false
fi

if [ "$runScript" = true ] ; then
  read -r -p "Execute? [y/N] " response
  case $response in
      [yY][eE][sS]|[yY])
          echo 'Executing'
          /bin/bash ./site_restore.sh $sourceEnvironment $destinationEnvironment
          /bin/bash ./database_restore.sh $sourceEnvironment $destinationEnvironment
          ;;
      *)
          echo 'Script Cancelled'
          ;;
  esac
fi
echo ''
echo ''
echo 'COMPLETED restore_all Script'
