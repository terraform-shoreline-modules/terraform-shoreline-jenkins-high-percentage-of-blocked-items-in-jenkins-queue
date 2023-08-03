
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High percentage of blocked items in Jenkins queue.
---

This incident type refers to a situation where there is a high percentage of blocked items in the Jenkins queue, which may be caused by various issues such as slow build or test execution times, network or server issues, or other performance-related problems. This can lead to delays in software development and deployment processes, resulting in longer wait times for developers and ultimately, slower time-to-market for software products.

### Parameters
```shell
# Environment Variables

export JENKINS_URL="PLACEHOLDER"

export JENKINS_NODE="PLACEHOLDER"

export NAME_OF_BUILD_AGENT="PLACEHOLDER"

export BUILD_AGENT_URL="PLACEHOLDER"

export MAX_LOAD="PLACEHOLDER"

export JENKINS_API_TOKEN="PLACEHOLDER"

export NEW_EXECUTORS="PLACEHOLDER"
```

## Debug

### Check Jenkins queue size
```shell
curl -s -X GET ${JENKINS_URL}/queue/api/json | jq '.items | length'
```

### Check if Jenkins queue is blocked
```shell
curl -s -X GET ${JENKINS_URL}/queue/api/json | jq '.items[].blocked'
```

### Check if Jenkins server is running
```shell
systemctl status jenkins
```

### Check if Jenkins is overloaded
```shell
top -bn1 | grep -Ei 'jenkins|java'
```

### Check if Jenkins is running out of memory
```shell
curl -s -X GET ${JENKINS_URL}/computer/api/json | jq '.computer[].executors[].currentExecutable.url' | xargs curl -s -X GET | jq '.actions[].causes[].shortDescription' | grep 'OutOfMemoryError'
```

### Check Jenkins logs for errors
```shell
tail -n 50 /var/log/jenkins/jenkins.log | grep -Ei 'error|exception'
```

### Check if there are any issues with the Jenkins node
```shell
ssh ${JENKINS_NODE} 'uptime; free -m; df -h'
```

### An issue with the build agents, such as agents being offline or misconfigured, causing the high percentage of blocked items in the queue.
```shell
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


```

### An issue with the Jenkins server, such as a bug in the Jenkins software or an overload of the server, causing the high percentage of blocked items in the queue.
```shell


#!/bin/bash



# Check if Jenkins is running

jenkins_status=$(systemctl status jenkins | grep "Active" | awk '{print $2}')



if [ "$jenkins_status" == "inactive" ]; then

  echo "Jenkins is not running"

  exit 1

fi



# Check if Jenkins is overloaded

queue_size=$(curl -s -X GET http://${JENKINS_URL}/queue/api/json | jq '.items | length')

blocked_items=$(curl -s -X GET http://${JENKINS_URL}/queue/api/json | jq '.items[].blocked')



if [ "$queue_size" -eq 0 ]; then

  echo "Jenkins queue is empty"

  exit 1

fi



if [ "$blocked_items" -gt "$queue_size" ]; then

  echo "Jenkins queue is overloaded with blocked items"

  exit 1

fi



echo "Jenkins is running and queue is processing normally"


```

## Repair

### Increase the number of executors on the Jenkins server to improve job processing and reduce queue blockages.
```shell
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

```