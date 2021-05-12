#!/bin/bash

export dxOrg="CoreFunctionalityAppScratch"
export dxUser="test-bwqfp9xky4fo@example.com"
export gitBranch="CoreFunctionality"

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
    echo "Enter new username: "
    read dxUser
fi
sfdx force:org:list
echo "$dxOrg Org has been created with user $dxUser, hit return to continue..."
read inpt

git pull origin $gitBranch
sfdx force:source:push -u $dxUser

sfdx force:org:open -u $dxOrg

#sfdx force:data:tree:export -q "select Id,Name from Profile WHERE Name='System Administrator'" -d ./data
#echo "Update the Profile Id AND username in the User.json file, hit return to continue..."
#read inpt

#sfdx force:data:tree:import --sobjecttreefiles data/User.json

echo "==========================================================================="
sfdx force:org:list
sfdx force:source:status
echo "==========================================================================="

echo "Reset org $dxOrg processing complete....."