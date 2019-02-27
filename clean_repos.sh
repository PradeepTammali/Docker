#!/bin/bash

# Color logging
RED="\033[1;31m"     # ERROR
GREEN="\033[1;32m"   # INFO
Blu='\e[0;34m'       # DEBUG
YELLOW="\033[33;33m" #WARN
NOCOLOR="\033[0m"

# Declaring and initializing varibles
WORK_DIR="/home/ubuntu"
SCRIPT="clean_repos.sh"

echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Executing $SCRIPT script....${NOCOLOR}"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Removing repositories.......${NOCOLOR}"

# Declaring and initializing array
declare -a repos
repos=(ui-client notification config ui-support images registry user email gateway authentication proxy proxy-support ingestion transformation nbapi)
for REPO in ${repos[@]}; do
	if [ -d "$WORK_DIR/$REPO" ]; then
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Removing $REPO repository...${NOCOLOR}"
		rm -rf "$WORK_DIR/$REPO"
	else
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${YELLOW}WARN: $REPO repository does not exist..${NOCOLOR}"
	fi
done
