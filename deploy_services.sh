#!/bin/bash

# Color Logging
RED="\033[1;31m"   # ERROR
GREEN="\033[1;32m" # INFO
NOCOLOR="\033[0m"
YELLOW="\033[33;33m" # WARN

# Initializing variables
WORK_DIR="/home/ubuntu"
DOCKER_SCRIPTS="$WORK_DIR/DockerScripts"
SCRIPT="deploy_services.sh"

# Environment variables to pass while building docker images
MONGO="mongodb://mongodbserver:27017"
KAFKA=10.20.20.1:9092
REDIS=10.20.20.2
IMAGES_ENV="-e!imagesRootDir="
USER_ENV="-e!mongodbConnectionString=$MONGO/db"
EMAIL_ENV="-e!mongodbConnectionString=$MONGO/db!-e!emailUsername=!-e!emailPassword=!-e!emailId='noreply@gmail.com'"
AUTHENTICATION_ENV="-e!mongodbConnectionString=$MONGO/db"
NBAPI_ENV="-e!NODE_ENV=development!-e!DB_NAME=test!-e!COLLECTIONS_NAME_ONE=collection_one!-e!COLLECTIONS_NAME_TWO=collection_two!-e!COLLECTIONS_NAME_THREE=collection_three!-e!MONGO_URL=$MONGO/test!-e!IP=localhost!-e!PORT=10014"
TRANSFORMATION_CONSUMER_ENV="-e!kafka=$KAFKA!-e!mongo=$MONGO/test!-e!database-name=test!-e!key=org.apache.kafka.common.serialization.StringSerializer!-e!value=org.apache.kafka.common.serialization.StringSerializer"
TRANSFORMATION_STREAM_ENV="-e!kafka-url=$KAFKA!-e!key=org.apache.kafka.common.serialization.StringSerializer!-e!value=org.apache.kafka.common.serialization.StringSerializer"
DATA_INGESTION_ENV="-e!KAFKA_URL=$KAFKA!-e!TOMCAT_PORT=8084"
CONFIG_ENV="-e!server.port=8081!-e!spring.data.mongodb.uri=$MONGO/db"
NOTIFICATION_ENV="-e!server.port=8082!-e!spring.data.mongodb.uri=$MONGO/db!-e!spring.profiles.active=local!-e!spring.redis.host=$REDIS"
UI_SUPPORT_ENV="-e!spring.data.mongodb.uri=$MONGO/db!-e!spring.profiles.active=local!-e!server.port=8083"

echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Executing $SCRIPT script....${NOCOLOR}"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building images with latest code.......${NOCOLOR}"

# Declaring and initializing Array repository*branch*typeofservice(java or node)*EnvironmentVaribles*SubDir
declare -a repos
repos=(registry*develop*node* gateway*develop*node* images*develop*node*$IMAGES_ENV* user*develop*node*$USER_ENV* email*develop*node*$EMAIL_ENV* authentication*develop*node*$AUTHENTICATION_ENV* tsc-repo*develop*node* nbapi*develop*node*$NBAPI_ENV*Data transformation*develop*java*$TRANSFORMATION_CONSUMER_ENV*KafkaConsumer transformation*develop*java*$TRANSFORMATION_STREAM_ENV*KafkaStream ingestion*develop*java*$INGESTION_ENV*KafkaRestProxy config*develop*java*$CONFIG_ENV* notification*develop*java*$NOTIFICATION_ENV* ui-support*develop*java*$UI_SUPPORT_ENV*)

# Disconnecting from VPN to build the services
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Disconnecting from VPN ......${NOCOLOR}"
while true; do
	PID=$(ps -ef | grep "openconnect" | grep -v grep | awk '{print $2}')
	if [ -z $PID ]; then
		break
	else
		kill -9 $PID
	fi
done

for i in ${repos[@]}; do
	IFS='*' read -ra REPO_BRANCH <<<$i
	REPO=${REPO_BRANCH[0]}
	BRANCH=${REPO_BRANCH[1]}
	SERVICE_TYPE=${REPO_BRANCH[2]}
	ENV_VARS=${REPO_BRANCH[3]}
	SUB_DIR_PATH=${REPO_BRANCH[4]}
	echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Deploying services with latest code.........${NOCOLOR}"
	if [ ! -d "$WORK_DIR/$REPO" ]; then
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Repository $REPO doesn't exist.${NOCOLOR}"
	else
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building and deploying for $REPO service.${NOCOLOR}"
		if [ $SERVICE_TYPE = "java" ]; then
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building image for $REPO $SERVICE_TYPE service.${NOCOLOR}"
			cd $WORK_DIR/$REPO/$SUB_DIR_PATH
			if [ $? -eq 0 ]; then
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building image for $REPO service.${NOCOLOR}"
				# Copying the docker script to current repository
				cp "$DOCKER_SCRIPTS/$REPO$SUB_DIR_PATH-Dockerfile" Dockerfile
				# Copying the proxy server to current repository for java services
				cp -r $WORK_DIR/proxy $WORK_DIR/$REPO/$SUB_DIR_PATH/proxy
				sudo rm .dockerignore
				# Bulding image
				docker build -t $REPO${SUB_DIR_PATH,,} .
				# Removing proxy server contents
				rm -rf $WORK_DIR/$REPO/$SUB_DIR_PATH/proxy
				# Running the container for the current image and passin env variables
				if [ -z $ENV_VARS ]; then
					echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building container for $REPO service.${NOCOLOR}"
					docker run -d --net='host' --name $REPO${SUB_DIR_PATH,,} $REPO${SUB_DIR_PATH,,}:latest
				else
					echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building container for $REPO service.${NOCOLOR}"
					docker run -d --net='host' --name $REPO${SUB_DIR_PATH,,} ${ENV_VARS//\!/ } $REPO${SUB_DIR_PATH,,}:latest
				fi
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: $REPO service has been build and deployed successfully.${NOCOLOR}"
				echo "********************************************************************************************************************************"
			else
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Error building image the $REPO service.${NOCOLOR}"
				echo "********************************************************************************************************************************"
			fi
			cd $WORK_DIR
		# Building Node services
		elif [ $SERVICE_TYPE = "node" ]; then
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building and deploying $REPO $SERVICE_TYPE service.${NOCOLOR}"
			cd $WORK_DIR/$REPO/$SUB_DIR_PATH
			if [ "$REPO" == "tcs-repo" ]; then
				cd $WORK_DIR/user
			fi
			if [ $? -eq 0 ]; then
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building image for $REPO service.${NOCOLOR}"
				# Copying the docker image to current repository
				cp "$DOCKER_SCRIPTS/$REPO$SUB_DIR_PATH-Dockerfile" Dockerfile
				sudo rm .dockerignore
				# Build docker image
				docker build -t $REPO${SUB_DIR_PATH,,} .
				# Running container for the current image
				if [ -z $ENV_VARS ]; then
					echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building container for $REPO service.${NOCOLOR}"
					docker run -d --net='host' --name $REPO${SUB_DIR_PATH,,} $REPO${SUB_DIR_PATH,,}:latest
				else
					echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building container for $REPO service.${NOCOLOR}"
					docker run -d --net='host' --name $REPO${SUB_DIR_PATH,,} ${ENV_VARS//\!/ } $REPO${SUB_DIR_PATH,,}:latest
				fi
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: $REPO service has been build and deployed successfully.${NOCOLOR}"
				echo "********************************************************************************************************************************"
			else
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Error in deploying $REPO service.${NOCOLOR}"
				echo "********************************************************************************************************************************"
			fi
			cd $WORK_DIR
		else
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Service type is not provided, Skipped building $REPO..${NOCOLOR}"
			echo "********************************************************************************************************************************"
			cd $WORK_DIR
		fi
	fi
done
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building the services or repositories is successfull...${NOCOLOR}"
exit 0
