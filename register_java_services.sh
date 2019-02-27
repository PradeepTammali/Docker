#!/bin/bash

# Color Logging
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

# Declaring and initializing variables
WORK_DIR="/home/ubuntu"
SCRIPT="register_java_services.sh"

echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Executing $SCRIPT script....${NOCOLOR}"
echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}INFO: Registering java services .......${NOCOLOR}"

# Registering java servies with registry service
node /home/ubuntu/proxy/build/proxy.js --address http://0.0.0.0:10015 --registry http://10.20.30.2:3000 --descriptor /home/ubuntu/transformation/KafkaConsumer/src/main/resources/descriptor.json &

node /home/ubuntu/proxy/build/proxy.js --address http://0.0.0.0:10016 --registry http://10.20.30.2:3000 --descriptor /home/ubuntu/notification/src/main/resources/descriptor.json &

node /home/ubuntu/proxy/build/proxy.js --address http://0.0.0.0:10017 --registry http://10.20.30.2:3000 --descriptor /home/ubuntu/ingestion/KafkaRestProxy/src/main/resources/descriptor.json &

node /home/ubuntu/proxy/build/proxy.js --address http://0.0.0.0:10018 --registry http://10.20.30.2:3000 --descriptor /home/ubuntu/ui-support/src/main/resources/descriptor.json &

node /home/ubuntu/proxy/build/proxy.js --address http://0.0.0.0:10019 --registry http://10.20.30.2:3000 --descriptor /home/ubuntu/config/src/main/resources/descriptor.json &

exit 0
