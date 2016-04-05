#!/bin/bash
#This script push changes to production BE CAREFULL!!
#By This script overwrites the file in your prod or developement
PROD_TARGET="s3://quickstart-reference/ansible/latest"
DEV_TARGET="s3://quickstart-dev/ansible/latest"
TARGET=$PROD_TARGET

pushcode () { 
   echo "ENDPOINT: $1/"
   aws s3 sync scripts/ $1/scripts --exclude="*.git/*"
   echo "ENDPOINT: $1/"
   aws s3 sync templates/ $1/templates --exclude="*.git/*"
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
	if [ $TARGET = $PROD_TARGET ]; then
                        read -p "Are you sure you want to update PROD=[$TARGET] [yes=y/no=n] " yn
                                case $yn in
                                        [Yy]* ) echo "Push to $TARGET" && pushcode $TARGET
                                        ;;
                                        [Nn]* ) echo "Exiting ...." && exit
                                        ;;
                                        * ) echo "Please answer y or n "
                                        ;;
                                esac
        elif [ $TARGET = $DEV_TARGET ]; then
                        echo "Push to $TARGET"; pushcode $TARGET
       	fi

else 
	echo "Commit your Changes first!"
	git add --all .
	git commit -a
	git push
	
	if [ $? -eq 0 ];then
		if [ $TARGET = $PROD_TARGET ]; then
			read -p "Are you sure you want to update PROD=[$TARGET] [yes=y/no=n] " yn
    				case $yn in
        				[Yy]* ) echo "Push to $TARGET" && pushcode $TARGET
					;;
        				[Nn]* ) echo "Exiting ...." && exit
					;;
        				* ) echo "Please answer y or n "
					;;
    				esac
		elif [ $TARGET = $DEV_TARGET ]; then
			echo "Push to $TARGET"; pushcode $TARGET
		fi
	else
		echo "Git push did was not clean (Please investigate)"
	fi
		
fi 
