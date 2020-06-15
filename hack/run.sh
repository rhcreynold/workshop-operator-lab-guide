#! /usr/bin/env bash
# Helper function to run the newly built containers in various locations

print_usage() {
  echo "Usage: ./run.sh WORKSHOP_NAME (setup|local|start|stop|remove) [(-p |--port=)PORT]" >&2
  echo "       [--project=QUAY_PROJECT_NAME] [(-e |--env-file=)ENV_FILE_PATH] [--test]" >&2
}

cd $(dirname $(realpath $0))/..

WORKSHOP_NAME=$1
shift
RUN_TYPE=$1
shift

# defaults
QUAY_PROJECT=creynold
PORT=8888
ENV_FILE=/tmp/env.list
do_tests=''

# If STUDENT_NAME is unset, check /etc/passwd for a student, otherwise default
#   to student1
export STUDENT_NAME=$(_PASSWD_STUDENT=$(awk -F: '/student/{ print $1 }' /etc/passwd);
                      echo ${STUDENT_NAME:-${_PASSWD_STUDENT:-student1}})

while [ $# -gt 0 ]; do
  case "$1" in
    --project=*)
      QUAY_PROJECT=$(echo "$1" | cut -d= -f2-)
      ;;
    -p|--port=*)
      if [ "$1" = '-p' ]; then
        shift
        PORT="$1"
      else
        PORT=$(echo "$1" | cut -d= -f2-)
      fi
      ;;
    -e|--env-file=*)
      if [ "$1" = '-e' ]; then
        shift
        ENV_FILE="$1"
      else
        ENV_FILE=$(echo "$1" | cut -d= -f2-)
      fi
      ;;
    --test)
      do_tests=true
      ;;
    *)
      print_usage
      exit 1
      ;;
  esac; shift
done

# Relies on options
CONTAINER_IMAGE=quay.io/$QUAY_PROJECT/operator-workshop-lab-guide-$WORKSHOP_NAME

# Create the podman run env.list file
setup_local() {
  stop_local

  echo "Creating the environment variables file at $ENV_FILE"
  echo "WORKSHOP_NAME=$WORKSHOP_NAME" > $ENV_FILE
  ENV_PREP_SCRIPT=prep-$WORKSHOP_NAME.sh
  if [ -f hack/$ENV_PREP_SCRIPT ]; then
    echo Running prep script
    hack/$ENV_PREP_SCRIPT $ENV_FILE $STUDENT_NAME
  fi

  remove_container

  echo Defining podman container from $CONTAINER_IMAGE
  podman create --env-file $ENV_FILE --name $WORKSHOP_NAME -p $PORT:8080 $CONTAINER_IMAGE

  echo Dropping systemd unit file
  mkdir -p $HOME/.config/systemd/user
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
WantedBy=multi-user.target
EOF
  systemctl --user daemon-reload

  echo Enabling systemd unit
  systemctl --user enable $WORKSHOP_NAME.service
}

stop_local() {
  if container_installed; then
    echo Stopping $WORKSHOP_NAME container
    systemctl --user stop $WORKSHOP_NAME.service
  fi
}

container_installed() {
  systemctl --user | grep -qF "$WORKSHOP_NAME Lab Guide container"
  return $?
}

start_local() {
  stop_local

  echo Running dedicated local build
  hack/build.sh $WORKSHOP_NAME local $QUAY_PROJECT || exit 1

  echo Ensuring setup complete
  container_installed || setup_local

  echo Starting systemd container for $WORKSHOP_NAME
  systemctl --user start $WORKSHOP_NAME
}

start() {
  stop_local

  echo Pulling image $CONTAINER_IMAGE
  podman pull $CONTAINER_IMAGE || exit 1

  echo Ensuring setup complete
  container_installed || setup_local

  echo Starting systemd container for $WORKSHOP_NAME
  systemctl --user start $WORKSHOP_NAME
}

remove_container() {
  existing_container=$(podman ps -a -f name=$WORKSHOP_NAME --format='{{ $.ID }}')
  if [ "$existing_container" ]; then
    echo Removing existing $WORKSHOP_NAME container ID $existing_container
    podman rm -f $existing_container
  fi
}

remove_local() {
  rm -f $ENV_FILE
  remove_container
  if container_installed; then
    systemctl --user stop $WORKSHOP_NAME.service
    systemctl --user disable $WORKSHOP_NAME.service
    rm -f $HOME/.config/systemd/user/$WORKSHOP_NAME.service
    systemctl --user daemon-reload
    systemctl --user reset-failed
  fi
  image_ids=$(podman images --filter label=$CONTAINER_IMAGE --format='{{ $.ID }}')
  if [ "$image_ids" ]; then
    podman rmi --force $(podman images --filter label=$CONTAINER_IMAGE --format='{{ $.ID }}')
  fi
}

testable=''
case $RUN_TYPE in
  setup)
    setup_local
  ;;
  start)
    start
    testable=true
  ;;
  local)
    start_local
    testable=true
  ;;
  stop)
    stop_local
  ;;
  remove)
    remove_local
  ;;
  *)
    print_usage
    exit 1
  ;;
esac

if [ -n "$do_tests" -a -n "$testable"]; then
  count=0
  step=5
  max_failures=12
  while ! curl 127.0.0.1:$PORT &>/dev/null; do
    (( count++ ))
    if [ $count -ge $max_failures ]; then
      echo "Failed attempt $count of $max_failures.... dumping logs" >&2
      echo
      echo systemctl --user status $WORKSHOP_NAME:
      systemctl --user status $WORKSHOP_NAME | sed 's/^/  /'
      echo journalctl --user -u $WORKSHOP_NAME:
      journalctl --user -u $WORKSHOP_NAME | sed 's/^/  /'
      exit 13
    fi
    echo "Failed attempt $count of $max_failures.... retrying in $step" >&2
    sleep $step
  done
  curl localhost:8888 |& grep -F '<title>'
  stop_local
fi
