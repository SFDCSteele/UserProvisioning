#!/bin/bash

export dxOrg="ActiveDirectoryAppScratch"
export dxUser="test-p9yeswr0dvzw@example.com"
export MDAPIUser="ActiveDirectory"
export gitBranch="ActiveDirectory"

echo "==========================================================================="
echo "Setting up Scratch Org $dxOrg as user $dxUser and pushing to branch $gitBranch to the Org"
echo "==========================================================================="

git pull origin $gitBranch

rm -rf ./src
echo "MDAPI source removed..."
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

sfdx force:mdapi:deploy -u $gitBranch -w 10 -d ./src
echo "MDAPI source deployed...press return to continue..."
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