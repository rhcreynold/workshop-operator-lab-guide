#! /usr/bin/env bash

ENV_FILE=$1

echo "Preparing environment variables for $WORKSHOP_NAME lab guide"

STUDENT_NAME=$(grep student /etc/passwd | awk -F':' '{ print $1 }')
if [[ ${#STUDENT_NAME} -eq 0 ]];then
  STUDENT_NAME=student1
fi
INVENTORY_FILE=/home/$STUDENT_NAME/devops-workshop/lab_inventory/hosts
if [ -f $INVENTORY_FILE ];then
  CONTROL_PRIVATE_IP=$(grep 'ansible ansible_host' $INVENTORY_FILE | awk -F'=' '{ print $2 }')
  STUDENT_PASS=$(grep ansible_ssh_pass $INVENTORY_FILE | awk -F= '{ print $2 }')
  CONTROL_PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
  NODE_1_IP=$(grep dev_web1 $INVENTORY_FILE | head -1 | awk -F'=' '{ print $2 }')
  NODE_2_IP=$(grep dev_web2 $INVENTORY_FILE | head -1 | awk -F'=' '{ print $2 }')
  NODE_3_IP=$(grep prod_web1 $INVENTORY_FILE | head -1 | awk -F'=' '{ print $2 }')
  NODE_4_IP=$(grep prod_web2 $INVENTORY_FILE | head -1 | awk -F'=' '{ print $2 }')
else
  CONTROL_PRIVATE_IP=10.0.0.1
  STUDENT_PASS=redhat01
  CONTROL_PUBLIC_IP=192.168.0.1
  NODE_1_IP=10.0.0.2
  NODE_2_IP=10.0.0.3
  NODE_3_IP=10.0.0.4
  NODE_4_IP=10.0.0.5
fi

echo "CONTROL_PRIVATE_IP="$CONTROL_PRIVATE_IP >> $ENV_FILE
echo "CONTROL_PUBLIC_IP="$CONTROL_PUBLIC_IP >> $ENV_FILE
echo "STUDENT_NAME="$STUDENT_NAME >> $ENV_FILE
echo "STUDENT_PASS="$STUDENT_PASS >> $ENV_FILE
echo "NODE_1_IP="$NODE_1_IP >> $ENV_FILE
echo "NODE_2_IP="$NODE_2_IP >> $ENV_FILE
echo "NODE_3_IP="$NODE_3_IP >> $ENV_FILE
echo "NODE_4_IP="$NODE_4_IP >> $ENV_FILE
