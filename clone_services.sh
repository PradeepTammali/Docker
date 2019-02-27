#!/bin/bash

# Color Logging
RED="\033[1;31m"   # ERROR
GREEN="\033[1;32m" # INFO
Blu='\e[0;34m'     # DEBUG
NOCOLOR="\033[0m"

# Declaring and initializing varibles
WORK_DIR="/home/ubuntu"
SCRIPT="clone_services.sh"

echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Executing $SCRIPT script....${NOCOLOR}"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Cloning latest code.......${NOCOLOR}"

# Declaring and initializing array
declare -a repos
repos=(ui-client:develop notification:develop config:develop ui-support:develop images:develop registry:develop user:develop email:develop gateway:develop authentication:develop proxy:develop proxy-support:master dataingestion:develop transformation:develop nbapi:develop)
for i in ${repos[@]}; do
	# split the repo names with field separator :
	IFS=':' read -ra REPO_BRANCH <<<$i
	REPO=${REPO_BRANCH[0]}
	BRANCH=${REPO_BRANCH[1]}
	echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Pulling latest code.........${NOCOLOR}"
	if [ -d "$WORK_DIR/$REPO" ]; then
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Pulling latest code for $REPO in $BRANCH branch${NOCOLOR}"
		cd "$WORK_DIR/$REPO"
		# If the repository exists then removing the local changes in the git repository and pulling the latest code from specified branch
		git stash
		git checkout $BRANCH
		git pull
		if [ $? -eq 0 ]; then
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Pulling is successfull for $REPO in $BRANCH branch${NOCOLOR}"
		else
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Error in pulling the latest code from git for $REPO in $BRANCH branch${NOCOLOR}"
		fi
		cd $WORK_DIR
	else
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${Blu}DEBUG: $REPO repository doesn't exist, cloning the repository in $BRANCH branch${NOCOLOR}"
		cd $WORK_DIR
		# If the repository does not exist then cloning it
		git clone ssh://google-gerrit/repos/$REPO -b $BRANCH
		if [ $? -eq 0 ]; then
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Pulling is successfull for $REPO in $BRANCH branch${NOCOLOR}"
		else
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Error in pulling the latest code from git for $REPO in $BRANCH branch${NOCOLOR}"
		fi
		cd $WORK_DIR
	fi
done
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Cloning is successfull...${NOCOLOR}"
exit 0
