#!/bin/bash

export dxOrg="ActiveDirectoryAppScratch"
export dxUser="test-akndp1zu44ia@example.com"
export gitBranch="ActiveDirectory"

echo "==========================================================================="
echo "Pulling changes from $dxOrg as user $dxUser and pushing to branch $gitBranch with the comment $1"
echo "version 100.11..."
echo "Options: "
echo "  Push to Scratch Org   : $1"
echo "  Push to Scratch GitHub: $2"
echo "==========================================================================="

rm -rf CF_Extract
#mkdir CF_Extract
rm -rf ./src
cp -vR ../../work/repo-CoreFunctionality/src ./
rm -rf ./src/CF_EXTRACT

#echo "looking for CF_EXTRACT..."
#echo "Listing ../../work/repo-CoreFunctionality/src"
#ls -al ../../work/repo-CoreFunctionality/src
#echo "listing ./"
#ls -al ./
#echo "Listing ./src"
#ls -al ./src
echo "src has been copied for converting...."
read inpt

#git fetch origin
#git reset --hard origin/CoreFunctionality

rm -rf force-app/main/default
rm -rf ./src/build

ls -al
ls -al src

#echo "==========================================================================="
#echo "Source to be converted has been copied.....press return to convert!"
#read inpt

sfdx force:mdapi:convert -r ./src

if [ "$1" = "Y" ]
then
    sfdx force:source:push -u test-bwqfp9xky4fo@example.com
fi

if [ "$2" = "Y" ]
then
    echo pushing to gitHub
    ./scripts/git_in '"Pushing converted code to GitHub"' CoreFunctionality
fi

#sfdx force:mdapi:convert -r ../../work/repo-CoreFunctionality/work/src/

#sfdx force:source:pull -u $dxUser

#git status
#git add .
#git commit -m "$1"
#git push origin $gitBranch

echo "==========================================================================="
echo "Processing complete....."