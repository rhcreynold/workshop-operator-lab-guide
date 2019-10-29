#! /usr/bin/env bash
# Helper script to build container images for each workshop
# if using podman, be sure to install the podman-docker package
# also, if using podman, up th

WORKSHOP_NAME=$1
if [[ ${#3} -eq 0 ]];then
  QUAY_PROJECT=creynold
else
  QUAY_PROJECT=$3
fi


case $2 in
  local)
    docker build --build-arg workshop_name=$WORKSHOP_NAME \
    -t quay.io/$QUAY_PROJECT/operator-workshop-lab-guide-$WORKSHOP_NAME \
    .
  ;;
  quay)
    # designed to be used by travis-ci, where the docker_* variables are defined
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin quay.io
    docker build --build-arg workshop_name=$WORKSHOP_NAME \
    -t quay.io/$QUAY_PROJECT/operator-workshop-lab-guide-$WORKSHOP_NAME .
    docker push quay.io/$QUAY_PROJECT/operator-workshop-lab-guide-$WORKSHOP_NAME
  ;;
  *)
    echo "usage: ./hack/build.sh <WORKSHOP_NAME> <LOCATION>"
  ;;
esac
