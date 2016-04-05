#!/bin/bash
#This script push changes to production BE CAREFULL!!
#By This script overwrites the file in your prod or developement
PROD_TARGET="s3://quickstart-reference/ansible/latest"
DEV_TARGET="s3://quickstart-dev/ansible/latest"
TARGET=$PROD_TARGET

pushcode () { 
   cd scripts
   echo "ENDPOINT: $1/scripts"
   aws s3 sync . $1/scripts
   cd ..
   cd template
   echo "ENDPOINT: $1/scripts"
   aws s3 sync . $1/template
   cd ..
}

# check for cli
if which aws >/dev/null; then
    echo "Looking for awscli:(found)"
else
    echo "Looking for awscli:(not found)"
    echo "Please install awscli and add it to the runtime path"
    exit 1;
fi

# check for git
if which git >/dev/null; then
    echo "Looking for git:(found)"
else
    echo "Looking for git:(not found)"
    echo "Please install git  and add it to the runtime path"
    echo "Before pushing to prob commit your code"
    exit 1;
fi

if [[ -z $(git status -s) ]]; then 
	echo "No uncommited changes found"; 
	echo "Push to $TARGET"
	pushcode $TARGET
else 
	echo "Commit your Changes first!"
	git add --all .
	git commit -a
	git push
	
	if [ $? -eq 0 ];then
		echo "Push to $TARGET"
		pushcode $TARGET
	else
		echo "Git push did was not clean (Please investigate)"
	fi
		
fi 


