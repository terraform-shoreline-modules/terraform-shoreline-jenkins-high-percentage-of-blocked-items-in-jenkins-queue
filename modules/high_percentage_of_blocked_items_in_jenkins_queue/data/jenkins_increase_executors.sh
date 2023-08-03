#!/bin/bash

# Set the Jenkins URL and API token

JENKINS_URL=${JENKINS_URL}

JENKINS_API_TOKEN=${JENKINS_API_TOKEN}

# Set the number of executors to increase to

NEW_EXECUTORS=${NEW_EXECUTORS}

# Get the current number of executors

CURRENT_EXECUTORS=$(curl --silent "${JENKINS_URL}/computer/api/json" | jq '.computer | .[].numExecutors')


# Check if the number of executors needs to be increased

if [ "$CURRENT_EXECUTORS" -lt "$NEW_EXECUTORS" ]; then

  # Increase the number of executors

  curl --silent --user "${JENKINS_API_TOKEN}:" -X POST "${JENKINS_URL}/computer/newConfig" \

       --data-urlencode "numExecutors=${NEW_EXECUTORS}"

  echo "Successfully increased the number of executors to ${NEW_EXECUTORS}."

else

  echo "The number of executors is already ${CURRENT_EXECUTORS}, no action needed."

fi