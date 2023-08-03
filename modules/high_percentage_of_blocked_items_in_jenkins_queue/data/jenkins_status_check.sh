

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