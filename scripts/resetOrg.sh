#!/bin/bash

export dxOrg="CoreFunctionalityAppScratch"
export dxUser="test-bwqfp9xky4fo@example.com"
export gitBranch="CoreFunctionality"

echo "==========================================================================="
echo "Setting up Scratch Org $dxOrg as user $dxUser and pushing to branch $gitBranch to the Org"
echo "==========================================================================="

#sfdx auth:web:login -d -a DevHub
#echo "Once DevHub is authorized, hit return to continue..."
#read inpt
if [ "$1" = "Y" ]
then
    sfdx force:org:create -s -f config/project-scratch-def.json -a $dxOrg --durationdays 30
fi


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