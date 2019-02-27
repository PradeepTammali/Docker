#!/bin/bash

# Color Logging
RED="\033[1;31m"   # ERROR
GREEN="\033[1;32m" # INFO
NOCOLOR="\033[0m"
YELLOW="\033[33;33m" # WARN

# Initializing variables
WORK_DIR="/home/ubuntu"
SCRIPT="update.sh"

# Declaring and initializing array of scripts which need to executed
declare -a SCRIPTS
SCRIPTS=(clone_services.sh build_services.sh remove_services.sh deploy_services.sh)

echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Executing $SCRIPT script...${NOCOLOR}"

if [ $# -eq 1 ]; then
	if [ $1 == "clean" ]; then
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Executing clean_repos.sh script...${NOCOLOR}"
		# Services will be removed and build again after giving clean as argument
		bash $WORK_DIR/clean_repos.sh
		if [ ! $? -eq 0 ]; then
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: clean_repos.sh script was unsuccesful, Exiting...${NOCOLOR}"
			exit 1
		fi
	fi
fi

for CUR_SCRIPT in ${SCRIPTS[@]}; do
	echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Running $CUR_SCRIPT script...${NOCOLOR}"
	# Executing script one by one
	bash $WORK_DIR/$CUR_SCRIPT
	if [ ! $? -eq 0 ]; then
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: $CUR_SCRIPT script was unsuccesful, Exiting...${NOCOLOR}"
		exit 1
	fi
done
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Updating is successfull...${NOCOLOR}"
exit 0
