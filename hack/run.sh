#! /usr/bin/env bash
# Helper function to run the newly built containers in various locations
# It assumes docker at this point.

WORKSHOP_NAME=$1
QUAY_USER=jduncan
TMP_FILE=/tmp/lab_guide_id_$WORKSHOP_NAME

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
  PRIVATE_IP=$(ip addr show eth0 | grep 'inet ' | awk '{ print $2 }' | awk -F/ '{ print $1 }')
  STUDENT_NAME=student1
  docker run -d -e PRIVATE_IP=$PRIVATE_IP -e STUDENT_NAME=$STUDENT_NAME -p 8080:8080 quay.io/$QUAY_USER/operator-workshop-lab-guide-$WORKSHOP_NAME &> $TMP_FILE
  if [ $? -eq 0 ]; then
    LAB_CONTAINER=$(cat $TMP_FILE | cut -c1-12)
    echo "$WORKSHOP_NAME is running as container ID $LAB_CONTAINER and is avaiable at http://localhost:8080"
  fi
}

case $2 in
  local)
    stop_local
    start_local
  ;;
  stop)
    stop_local
  ;;
  *)
    echo "Valid locations: 'local'"
    echo "Usage: ./run.sh <WORKSHOP_NAME> <TARGET>"
  ;;
esac
