bash

#!/bin/bash



# Define variables

BUILD_AGENT_NAME="${NAME_OF_BUILD_AGENT}"

BUILD_AGENT_STATUS="$(curl -s -o /dev/null -w '%{http_code}' http://${BUILD_AGENT_URL}/status)"



# Check if build agent is offline

if [[ "$BUILD_AGENT_STATUS" -ne 200 ]]; then

    echo "ERROR: $BUILD_AGENT_NAME is offline or misconfigured."

    echo "Please check the status of $BUILD_AGENT_NAME and ensure it is properly configured."

    exit 1

else

    echo "$BUILD_AGENT_NAME is online and properly configured."

    exit 0

fi