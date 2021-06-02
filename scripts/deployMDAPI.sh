#!/bin/bash

export dxOrg="UserProvisioningAppScratch"
export dxUser="wsteele@wsteele-20210208-1.demo.dest"
export MDAPIUser="UserProvisioning"
export gitBranch="UserProvisioning"

echo "==========================================================================="
echo "Setting up Scratch Org $dxOrg as user $dxUser and pushing to branch $gitBranch to the Org"
echo "==========================================================================="

git pull origin $gitBranch

rm -rf ./src
echo "MDAPI source removed...pausing briefly...hit return to continue"
read inpt

sfdx force:source:convert \
    -d ./src \
    -n "$gitBranch"

ls -al
echo "MDAPI source converted from source format..."
read inpt

if [ "$1" = "Y" ] 
then
    sfdx auth:web:login -d -a $MDAPIUser
fi

echo "Deploying via MetaData API to DEST1($MDAPIUser)..."
read inpt

sfdx force:mdapi:deploy -u $MDAPIUser -w 10 -d ./src
echo "MDAPI DEST1 source deployed...press return to continue..."
read inpt

export MDAPIUser="UserProvisoning2"
echo "Deploying via MetaData API to DEST2($MDAPIUser)..."
if [ "$1" = "Y" ] 
then
    sfdx auth:web:login -d -a $MDAPIUser
fi


sfdx force:mdapi:deploy -u $MDAPIUser -w 10 -d ./src
echo "MDAPI DEST2 source deployed...press return to continue..."
read inpt



git status
git add .
git commit -m "Source format converted to MDAPI"
git push origin $gitBranch

echo "==========================================================================="
sfdx force:org:list
sfdx force:source:status
echo "==========================================================================="

echo "Reset org $dxOrg processing complete....."