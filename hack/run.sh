#! /usr/bin/env bash
# Helper function to run the newly built containers in various locations

cd $(dirname $(realpath $0))/..

WORKSHOP_NAME=$1
RUN_TYPE=$2
QUAY_PROJECT=${3:-rhcreynold}
PORT=${4:-8888}
ENV_FILE=${5:-/tmp/env.list}
CONTAINER_IMAGE=quay.io/$QUAY_PROJECT/operator-workshop-lab-guide-$WORKSHOP_NAME
# If STUDENT_NAME is unset, check /etc/passwd for a student, otherwise default
#   to student1
STUDENT_NAME=$(_PASSWD_STUDENT=$(awk -F: '/student/{ print $1 }' /etc/passwd);
               echo ${STUDENT_NAME:-${_PASSWD_STUDENT:-student1}})

# Create the podman run env.list file
echo "Creating the environment variables file at $ENV_FILE"
echo "WORKSHOP_NAME=$WORKSHOP_NAME" > $ENV_FILE

setup_local() {
  stop_local

  existing_container=$(podman ps -a -f name=$WORKSHOP_NAME --format='{{ $.ID }}')
  if [ "$existing_container" ]; then
    echo Removing existing $WORKSHOP_NAME container ID $existing_container
    podman rm -f $existing_container
  fi

  echo Defining podman container from $CONTAINER_IMAGE
  podman create --env-file $ENV_FILE --name $WORKSHOP_NAME -p $PORT:8080 $CONTAINER_IMAGE

  echo Dropping systemd unit file
  cat << EOF > $HOME/.config/systemd/user/$WORKSHOP_NAME.service
[Unit]
Description=$WORKSHOP_NAME Lab Guide container
Wants=network.target multi-user.target
After=network.target

[Service]
Restart=always
ExecStart=/usr/bin/podman start -a $WORKSHOP_NAME
ExecStop=/usr/bin/podman stop -t 2 $WORKSHOP_NAME

[Install]
WantedBy=local.target
EOF
  systemctl --user daemon-reload

  echo Enabling systemd unit
  systemctl --user enable $WORKSHOP_NAME.service
}

stop_local() {
  if systemctl --user | grep -qF $WORKSHOP_NAME; then
    echo Stopping $WORKSHOP_NAME container
    systemctl --user stop $WORKSHOP_NAME.service
  else
    echo No lab guide for $WORKSHOP_NAME installed
  fi
}

start_local() {
  stop_local

  echo Ensuring setup complete
  systemctl --user | grep -qF $WORKSHOP_NAME || setup_local

  ENV_PREP_SCRIPT=prep-$WORKSHOP_NAME.sh
  if [ -f hack/$ENV_PREP_SCRIPT ]; then
    hack/$ENV_PREP_SCRIPT $ENV_FILE $STUDENT_NAME
  fi

  podman pull $CONTAINER_IMAGE

  echo Starting systemd container for $WORKSHOP_NAME
  systemctl --user start $WORKSHOP_NAME
}

case $2 in
  setup)
    setup_local
  ;;
  start)
    start_local
  ;;
  local)
    start_local
  ;;
  stop)
    stop_local
  ;;
  *)
    echo "Usage: ./run.sh WORKSHOP_NAME (setup|local|start|stop) [QUAY_PROJECT_NAME] [PORT] [ENV_FILE_PATH]" >&2
  ;;
esac
