#! /bin/sh

AGENT_NAME=${1}
AGENT_SECRET=${2}


echo "Check if the secret or name has changed and kill the current java process if it has. "

cron_entry=$(crontab -l | grep jenkins-slave.sh)
cron_name_and_secret=$(echo "$cron_entry" | grep -o "$AGENT_NAME .*")

if [[ "$AGENT_NAME $AGENT_SECRET" != "$cron_name_and_secret" ]]; then
  pgrep java | xargs kill -9
fi


echo "Run the agent startup script in the background. "

$HOME/jenkins-slave.sh $AGENT_NAME $AGENT_SECRET &


echo "Wait for the script to get to its hang point. "

sleep 5


echo "Check that the script has connected the agent to the controller. "

jenkins_json=$(curl https://builds.mantidproject.org/manage/computer/$AGENT_NAME/api/json)
is_offline=$(echo "$jenkins_json" | grep \"icon\":\"symbol-computer-offline\")

if [[ $is_offline ]]; then
  echo "Agent failed to connect to Jenkins controller. "
  exit 1
fi


echo "Agent connected successfully. "

exit 0
