#! /usr/bin/env bash
# Helper function to run the newly built containers in various locations
# It assumes docker at this point.

WORKSHOP_NAME=$1
QUAY_USER=jduncan
TMP_FILE=/tmp/lab_guide_id_$WORKSHOP_NAME
ENV_FILE=/tmp/env.list
STUDENT_NAME=$(grep student /etc/passwd | awk -F':' '{ print $1 }')
INVENTORY_FILE=/home/$STUDENT_NAME/devops-workshop/lab_inventory/hosts
CONTROL_PRIVATE_IP=$(grep 'ansible ansible_host' $INVENTORY_FILE | awk -F'=' '{ print $2 }')
STUDENT_PASS=grep ansible_ssh_pass $INVENTORY_FILE | awk -F= '{ print $2 }'
CONTROL_PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
NODE_1_IP=$(grep node1 $INVENTORY_FILE | awk -F'=' '{ print $2 }')
NODE_2_IP=$(grep node2 $INVENTORY_FILE | awk -F'=' '{ print $2 }')
NODE_3_IP=$(grep node3 $INVENTORY_FILE | awk -F'=' '{ print $2 }')
NODE_4_IP=$(grep node4 $INVENTORY_FILE | awk -F'=' '{ print $2 }')

# Create the docker run env.list file
echo "creating the env.list file at $ENV_FILE"

echo "WORKSHOP_NAME="$WORKSHOP_NAME > $ENV_FILE
echo "QUAY_USER="$QUAY_USER >> $ENV_FILE
echo "TMP_FILE="$TMP_FILE >> $ENV_FILE
echo "CONTROL_PRIVATE_IP="$CONTROL_PRIVATE_IP >> $ENV_FILE
echo "CONTROL_PUBLIC_IP="$CONTROL_PUBLIC_IP >> $ENV_FILE
echo "STUDENT_NAME="$STUDENT_NAME >> $ENV_FILE
echo "STUDENT_PASS="$STUDENT_PASS >> $ENV_FILE
echo "NODE_1_IP="$NODE_1_IP >> $ENV_FILE
echo "NODE_2_IP="$NODE_2_IP >> $ENV_FILE
echo "NODE_3_IP="$NODE_3_IP >> $ENV_FILE
echo "NODE_4_IP="$NODE_4_IP >> $ENV_FILE

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
  docker run -d --env-file /tmp/env.list -p 8080:8080 quay.io/$QUAY_USER/operator-workshop-lab-guide-$WORKSHOP_NAME &> $TMP_FILE
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
