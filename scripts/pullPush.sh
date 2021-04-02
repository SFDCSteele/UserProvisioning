#!/bin/bash

export dxOrg="CoreFunctionalityAppScratch"
export dxUser="test-bwqfp9xky4fo@example.com"
export gitBranch="CoreFunctionality"

echo "==========================================================================="
echo "Pulling changes from $dxOrg as user $dxUser and pushing to branch $gitBranch with the comment $1"
echo "==========================================================================="

sfdx force:source:pull -f -u $dxUser

git status
git add .
git commit -m "$1"
git push origin $gitBranch

echo "==========================================================================="
echo "Processing complete....."