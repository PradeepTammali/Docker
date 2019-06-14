#!/bin/bash

# Color logging
RED="\033[1;31m"   # ERROR
GREEN="\033[1;32m" # INFO
NOCOLOR="\033[0m"
YELLOW="\033[33;33m" # WARN

# Declaration of variables
WORK_DIR="/home/ubuntu"
SCRIPT="build_services.sh"
CLONE_SCRIPT="clone_services.sh"

echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Executing $SCRIPT script....${NOCOLOR}"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building with latest code.......${NOCOLOR}"
# Declaring and initializing Array repository:branch:typeofservice(java or node):subdirectoryfolder
declare -a repos
repos=(proxy-support:master:java: tsc-repo:develop:node:tsc-repo-dir notification:develop:java: config:develop:java: ui-support:develop:java: images:develop:node: registry:develop:node:Registry user:develop:node: email:develop:node: gateway:develop:node: authentication:develop:node: proxy:develop:node: ingestion:develop:java:KafkaRestProxy transformation:develop:java:KafkaConsumer transformation:develop:java:KafkaStream nbapi:develop:node:Data)
# Connecting to VPN
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Checking if connected to VPN.........${NOCOLOR}"
PID=$(ps -ef | grep "openconnect" | grep -v grep | awk '{print $2}')
# Checking if connected to VPN
if [ -z $PID ]; then
	echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${YELLOW}WARN: Not connected to VPN........., Exiting.\n Try using these \nopenconnect webvpn.us.vpn.com\nopenconnect webvpn.hk.vpn.com\nopenconnect webvpn.sn.vpn.com\nopenconnect webvpn.cn.vpn.com${NOCOLOR}"
	exit 1
else
	echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Connection estabished with VPN.......${NOCOLOR}"
fi

# Looping through the repositories
for i in ${repos[@]}; do
	# split the repo names with field separator :
	IFS=':' read -ra REPO_BRANCH <<<$i
	REPO=${REPO_BRANCH[0]}
	BRANCH=${REPO_BRANCH[1]}
	SERVICE_TYPE=${REPO_BRANCH[2]}
	SUB_DIR_PATH=${REPO_BRANCH[3]}
	echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building latest code.........${NOCOLOR}"
	if [ ! -d "$WORK_DIR/$REPO" ]; then
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${YELLOW}WARN: Repository $REPO doesn't exist, Running $CLONE_SCRIPT script.${NOCOLOR}"
		# If the repository does not exist cloning them
		bash $WORK_DIR/$CLONE_SCRIPT
		if [ $? -eq 0 ]; then
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Cloning the repositories is successfull..${NOCOLOR}"
		else
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Error in cloning the repositories....${NOCOLOR}"
		fi
	else
		echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building $REPO repository in $BRANCH branch.${NOCOLOR}"
		if [ $SERVICE_TYPE = "java" ]; then
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building $REPO $SERVICE_TYPE service.${NOCOLOR}"
			cd $WORK_DIR/$REPO/$SUB_DIR_PATH
			# Building the java servies with maven
			mvn clean install
			if [ $? -eq 0 ]; then
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Build successfull for $REPO service.${NOCOLOR}"
				echo "********************************************************************************************************************************"
			else
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Error building the $REPO service.${NOCOLOR}"
				echo "********************************************************************************************************************************"
			fi
			cd $WORK_DIR
		elif [ $SERVICE_TYPE = "node" ]; then
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building $REPO $SERVICE_TYPE service.${NOCOLOR}"
			cd $WORK_DIR/$REPO/$SUB_DIR_PATH
			if [ "$REPO" == "tsc-repo" ]; then
				cd $WORK_DIR/user/tsc-repo-dir
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Downloading $REPO node modules.${NOCOLOR}"
				sudo rm -rf node_modules
				# Downloading npm modules
				sudo npm install
				if [ $? -eq 0 ]; then
					echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building the $REPO service.${NOCOLOR}"
					# Building tcs-repo service
					tsc --sourcemap ./tsc-service.ts --target ES6 --module commonjs
					continue
				else
					echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Error in downloading node modules for $REPO service.${NOCOLOR}"
				fi
			fi
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Downloading $REPO node modules.${NOCOLOR}"
			# Removing old node modules
			sudo rm -rf node_modules
			# Installing node modules
			sudo npm install
			if [ $? -eq 0 ]; then
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building the $REPO service.${NOCOLOR}"
				# Building node service
				sudo npm run build
			else
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Error in downloading node modules for $REPO service.${NOCOLOR}"
			fi
			if [ $? -eq 0 ]; then
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Build successfull for $REPO service.${NOCOLOR}"
				echo "********************************************************************************************************************************"
			else
				echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Error building the $REPO service.${NOCOLOR}"
				echo "********************************************************************************************************************************"

			fi
			cd $WORK_DIR
		else
			echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}ERROR: Service type is not provided, Skipped building $REPO..${NOCOLOR}"
			cd $WORK_DIR
		fi
	fi
done
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Building the services or repositories is successfull...${NOCOLOR}"
exit 0
