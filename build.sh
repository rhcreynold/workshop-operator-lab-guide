#! /usr/bin/env bash
# Helper script to build container images for each workshop

WORKSHOP_NAME=$1
QUAY_USER=jduncan

case $2 in
  local)
    docker build --build-arg workshop_name=$WORKSHOP_NAME \
    -t quay.io/$QUAY_USER/operator-workshop-lab-guide-$WORKSHOP_NAME \
    .
  ;;
  quay)
    # designed to be used by travis-ci, where the DOCKER_* variables are defined
    # We will loop through all existing workshops to build out images and push them to quay.io
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin quay.io
    for i in $(ls workshops);do
      docker build --build-arg workshop_name=$WORKSHOP_NAME \
      -t quay.io/$DOCKER_USERNAME/operator-workshop-lab-guide-$WORKSHOP_NAME .
      docker push quay.io/$QUAY_USER/operator-workshop-lab-guide-$WORKSHOP_NAME
    done 
  ;;
  *)
    echo "usage: build.sh <WORKSHOP_NAME> <LOCATION>"
  ;;
esac
