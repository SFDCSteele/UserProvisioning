#!/bin/bash

export dxOrg="ActiveDirectoryAppScratch"
export dxUser="test-3hz0yojewuba@example.com"
export gitBranch="ActiveDirectory"

echo "==========================================================================="
echo "Pulling changes from $dxOrg as user $dxUser and pushing to branch $gitBranch with the comment $1"
echo "==========================================================================="

sfdx force:source:pull -u $dxUser

git status
git add .
git commit -m "$1"
git push origin $gitBranch

echo "==========================================================================="
echo "Processing complete....."