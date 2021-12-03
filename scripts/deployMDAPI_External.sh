#!/bin/bash

export dxOrg="CoreFunctionalityAppScratch"
export dxUser="test-dnwzjultoxar@example.com"
export MDAPIUser="CoreFunctionality"
export gitBranch="CoreFunctionality"
export dev_branch="main"
export repo_name=git@github.com:SFDCSteele/DTCApplication.git


echo "==========================================================================="
echo "Setting up Scratch Org $dxOrg as user $dxUser and pushing to branch $gitBranch to the Org"
echo "==========================================================================="

if [ "$1" != "SKIP" ]
then
    echo "============================================"
    echo "Pulling branch $dev_branch for deployment..."

    git pull origin $gitBranch
fi


if [ "$2" != "SKIP" ]
then
    echo "============================================"
    echo "Removing ./$4 to prepare for conversion..."

    rm -rf ./$4
    echo "MDAPI source removed...pausing briefly...hit return to continue"
    read inpt

    sfdx force:source:convert \
        -d ./$4 \
        -n "$gitBranch"

    ls -al
    echo "MDAPI source converted from source format..."
    read inpt
fi

if [ "$3" = "Y" ] 
then
    sfdx auth:web:login -d -a $MDAPIUser
fi


sfdx force:mdapi:deploy -u $gitBranch -w 10 -d ./$4
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