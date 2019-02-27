#!/bin/bash

# Color Logging
RED="\033[1;31m"   # ERROR
GREEN="\033[1;32m" # INFO
NOCOLOR="\033[0m"
YELLOW="\033[33;33m" # WARN

# Initializing variables
WORK_DIR="/home/ubuntu"
DOCKER_SCRIPTS="$WORK_DIR/DockerScripts"
SCRIPT="remove_services.sh"

echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Executing $SCRIPT script....${NOCOLOR}"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Removing all the services.......${NOCOLOR}"

# Declaring and initializing Array repository*branch*typeofservice(java or node)*EnvironmentVaribles*SubDir
declare -a repos
repos=(registry*develop*node* gateway*develop*node* images*develop*node*$IMAGES_ENV* user*develop*node*$USER_ENV* email*develop*node*$EMAIL_ENV* authentication*develop*node*$AUTHENTICATION_ENV* tsc-repo*develop*node* nbapi*develop*node*$NBAPI_ENV*Data transformation*develop*java*$TRANSFORMATION_CONSUMER_ENV*KafkaConsumer transformation*develop*java*$TRANSFORMATION_STREAM_ENV*KafkaStream ingestion*develop*java*$INGESTION_ENV*KafkaRestProxy config*develop*java*$CONFIG_ENV* notification*develop*java*$NOTIFICATION_ENV* ui-support*develop*java*$UI_SUPPORT_ENV*)

for i in ${repos[@]}; do
	# Split the repos with field separator *
	IFS='*' read -ra REPO_BRANCH <<<$i
	REPO=${REPO_BRANCH[0]}
	BRANCH=${REPO_BRANCH[1]}
	SERVICE_TYPE=${REPO_BRANCH[2]}
	ENV_VARS=${REPO_BRANCH[3]}
	SUB_DIR_PATH=${REPO_BRANCH[4]}
	echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Removing services.........${NOCOLOR}"
	if [ ! -d "$WORK_DIR/$REPO" ]; then
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Repository $REPO doesn't exist.${NOCOLOR}"
	else
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Removing $REPO service.${NOCOLOR}"
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Removing image for $REPO $SERVICE_TYPE service.${NOCOLOR}"
		cd $WORK_DIR/$REPO
		if [ $? -eq 0 ]; then
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Removing image for $REPO service is successfull.${NOCOLOR}"
			# Deleting container and image
			docker container rm -f $REPO${SUB_DIR_PATH,,}
			docker rmi $REPO${SUB_DIR_PATH,,}:latest
			echo "********************************************************************************************************************************"
		else
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Error removing image the $REPO service.${NOCOLOR}"
			echo "********************************************************************************************************************************"
		fi
		cd $WORK_DIR
	fi
done
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Removing the registered services...${NOCOLOR}"
PIDS=$(ps -ef | grep "node" | awk '{print $2}')
for PID in $PIDS; do
	echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${YELLOW}WARN: Killing process with PID: $PID...${NOCOLOR}"
	kill -9 $PID
done
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Removing the services or repositories is successfull...${NOCOLOR}"
exit 0
