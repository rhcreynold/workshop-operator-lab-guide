#! /usr/bin/env bash
# Helper function to run the newly built containers in various locations
# It assumes docker at this point.

WORKSHOP_NAME=$1

case $2 in
  local)
    echo "Preparing $WORKSHOP_NAME"
    docker run -d -p 8080:8080 operator-workshop-lab-guide-$WORKSHOP_NAME
    echo "$WORKSHOP_NAME is avaiable at http://localhost:8080"
  ;;
  *)
    echo "Usage: ./run.sh <WORKSHOP_NAME> <LOCATION>"
  ;;
esac
