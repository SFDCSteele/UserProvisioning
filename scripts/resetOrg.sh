#!/bin/bash

export dxOrg="ActiveDirectoryAppScratch"
export dxUser="test-pypzrfk2a5hj@example.com"
export gitBranch="ActiveDirectory"

echo "==========================================================================="
echo "Setting up Scratch Org $dxOrg as user $dxUser and pushing to branch $gitBranch to the Org"
echo "Authorizing to DevHub   : $1"
echo "Creating new scratch org: $2"
echo "==========================================================================="

if [ "$1" = "Y" ]
then
    sfdx auth:web:login -d -a DevHub
    echo "Once DevHub is authorized, hit return to continue..."
    read inpt
fi

if [ "$2" = "Y" ]
then
    sfdx force:org:create -s -f config/project-scratch-def.json -a $dxOrg --durationdays 30
    sfdx force:user:password:generate
fi
sfdx force:org:list
echo "Org has been created, hit return to continue..."
read inpt

git pull origin $gitBranch
sfdx force:source:push -u $dxUser

#sfdx force:org:open -u $dxUser

#sfdx force:data:tree:export -q "select Id,Name from Profile WHERE Name='System Administrator'" -d ./data
#echo "Update the Profile Id AND username in the User.json file, hit return to continue..."
#read inpt

#sfdx force:data:tree:import --sobjecttreefiles data/User.json

echo "==========================================================================="
sfdx force:org:list
sfdx force:source:status
echo "==========================================================================="

echo "Reset org $dxOrg processing complete....."