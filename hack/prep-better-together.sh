#! /usr/bin/env bash

ENV_FILE=$1

echo "Preparing environment variables for $WORKSHOP_NAME lab guide"

STUDENT_NAME=$(grep student /etc/passwd | awk -F':' '{ print $1 }')
if [[ ${#STUDENT_NAME} -eq 0 ]];then
  STUDENT_NAME=student1
fi
STUDENT_PASS=redhat01
OPENSHIFT_VER=3.11
CONTROL_PUBLIC_IP=192.168.10.1
LAB_DOMAIN=apps.example.com

echo "OPENSHIFT_VER="$OPENSHIFT_VER >> $ENV_FILE
echo "CONTROL_PUBLIC_IP="$CONTROL_PUBLIC_IP >> $ENV_FILE
echo "STUDENT_NAME="$STUDENT_NAME >> $ENV_FILE
echo "STUDENT_PASS="$STUDENT_PASS >> $ENV_FILE
echo "LAB_DOMAIN="$LAB_DOMAIN >> $ENV_FILE
