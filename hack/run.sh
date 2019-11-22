#! /usr/bin/env bash
# Helper function to run the newly built containers in various locations
# It assumes docker at this point.

WORKSHOP_NAME=$1
RUN_TYPE=$2
QUAY_USER=creynold
TMP_FILE=/tmp/lab_guide_id_$WORKSHOP_NAME
ENV_FILE=/tmp/env.list
CONTAINER_IMAGE=quay.io/$QUAY_USER/operator-workshop-lab-guide-$WORKSHOP_NAME
if [[ ${#3} -eq 0 ]];then
  PORT=8888
else
  PORT=$3
fi

# Create the docker run env.list file
echo "creating the environment variables file at $ENV_FILE"

echo "WORKSHOP_NAME="$WORKSHOP_NAME > $ENV_FILE

stop_local() {
  if [ -f $TMP_FILE ]; then
    LAB_CONTAINER=$(cat $TMP_FILE | cut -c1-12)
    echo "Stopping $WORKSHOP_NAME container ID $LAB_CONTAINER"
    docker rm -f $LAB_CONTAINER > /dev/null
    if [ $? -eq 0 ]; then
      echo "Lab Guide for $WORKSHOP_NAME stopped"
      rm -f $TMP_FILE
    fi
  else
    echo "No lab guides are currently running"
  fi
}

start_local() {
  echo "Preparing new lab guide for $WORKSHOP_NAME"
  if [[ $RUN_TYPE = 'start' ]]; then
    docker pull $CONTAINER_IMAGE
  fi
  ENV_PREP_SCRIPT=prep-$WORKSHOP_NAME.sh
  if [ -f ./hack/$ENV_PREP_SCRIPT ]; then
    ./hack/$ENV_PREP_SCRIPT $ENV_FILE
  fi
  docker run -d --env-file /tmp/env.list --name lab_guide_$WORKSHOP_NAME -p $PORT:8080 $CONTAINER_IMAGE &> $TMP_FILE
  if [ $? -eq 0 ]; then
    LAB_CONTAINER=$(cat $TMP_FILE | cut -c1-12)
    echo "$WORKSHOP_NAME is running as container ID $LAB_CONTAINER and is avaiable at http://localhost:$PORT"
  fi
  rm -f $ENV_FILE
}

case $2 in
  start)
    stop_local
    start_local
  ;;
  local)
    stop_local
    start_local
  ;;
  stop)
    stop_local
  ;;
  *)
    echo "Usage: ./run.sh <WORKSHOP_NAME> <TARGET>"
    echo "Valid targets: 'local', 'start', 'stop'"
  ;;
esac
