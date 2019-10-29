# Containerized Lab Guide Hack Scripts

## build.sh

This script builds out a container image for a specific lab guide. It takes up to 3 parameters.

1. Name of the workshop to build. This needs to correspond with the directory name for your workshop in the `workshops` directory.
2. Build target - `local` or `quay`.
  * `local` - the container is built and available in the host's container cache.
  * `quay` - it's built, cached, and also pushed to quay.io. Requirements for quay would be to be logged in to your runtime to authenticate against quay.io. The images are named using `quay.io/<quay_namespace>/operator-workshop-lab-guide-<workshop_name>`.
3. (optional) - Quay namespace tag. By default, this is `creynold` (makes it easier for the author). You can specify a different quay namespace using this parameter.

## run.sh

This script runs containers in various environments. It's useful for testing, QA, or even running lab guides in environments that lack OpenShift or kubernetes. It takes up to 3 parameters.

1. Name of the workshop to build. This needs to correspond with the directory name for your workshop in the `workshops` directory.
2. Build target - `local`, `start`, or `stop`
  * `local` - Runs the named workshop, using only the local container cache. This is useful when testing out a new build that hasn't been pushed to quay.io yet.
  * `start` - Runs the named workshop, but pulls the latest image from quay.io and uses that as the image to run the container from
  * `stop` - Stops the specified workshop
3. (optional) - container host port. If not specified, the lab guide serves on port 8080. This is useful if you want to run multiple lab guides simultaneously or if you need to not use the standard port.

### Dynamic content

One of the most interesting things about this project is its ability to take environment variables in a container and add them dynamically to the Sphinx content in your project. To do this easily, use a `prep` script in concert with `conf.py` in your Sphinx project.

#### Prep script

Prep scripts live in the `hack` directory, using the `prep-<workshop-name>.sh` name format. The goal of this script is to account for any dynamic content you want in your lab guide, an add that to an environment file that's read into docker. For OpenShift-based deployments, these variables are handled by the deployment or deploymentConfig resources. The example below accounts for dynamic content in a linklight-based environment, as well as a standalone testing environment. It's all simple bash with some tests and conditionals. The goal is to have an environment file that is used in `run.sh` when starting up the container.

```
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
  NODE_1_IP=$(grep node1 $INVENTORY_FILE | awk -F'=' '{ print $2 }')
  NODE_2_IP=$(grep node2 $INVENTORY_FILE | awk -F'=' '{ print $2 }')
  NODE_3_IP=$(grep node3 $INVENTORY_FILE | awk -F'=' '{ print $2 }')
  NODE_4_IP=$(grep node4 $INVENTORY_FILE | awk -F'=' '{ print $2 }')
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
```

#### conf.py

`conf.py` is the primary configuration file for sphinx-docs. To take the environment variables and make them sphinx subsitutions, we use the `rst_prolog` parameter. This takes the environment variables and makes them available as substitutions in your sphinx project using [their standard process](http://docutils.sourceforge.net/docs/ref/rst/directives.html#replacement-text).

```
rst_prolog = """
.. |workshop_name_clean| replace:: %s
.. |workshop_name| replace:: %s
.. |student_name| replace:: %s
.. |student_pass| replace:: %s
.. |control_public_ip| replace:: %s
.. |node_1_ip| replace:: %s
.. |node_2_ip| replace:: %s
.. |node_3_ip| replace:: %s
.. |node_4_ip| replace:: %s
""" % (project_clean,
       os.environ['WORKSHOP_NAME'],
       os.environ['STUDENT_NAME'],
       os.environ['STUDENT_PASS'],
       os.environ['CONTROL_PUBLIC_IP'],
       os.environ['NODE_1_IP'],
       os.environ['NODE_2_IP'],
       os.environ['NODE_3_IP'],
       os.environ['NODE_4_IP'],
       )
```

#### how this works

Sphinx is a static content generator. So dynamic content isn't possible. But this project actually takes those variables and renders the text within the container before starting to serve it. That means any time you redeploy a container to reflect a change, the content is re-generated and is therefore (sorta') dynamic.
