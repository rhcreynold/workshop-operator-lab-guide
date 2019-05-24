# Containerized Lab Guide Hack Scripts

## build.sh

This script builds out a container image for a specific lab guide. It takes up to 3 parameters.

1. Name of the workshop to build. This needs to correspond with the directory name for your workshop in the `workshops` directory.
2. Build target - `local` or `quay`.
  * `local` - the container is built and available in the host's container cache.
  * `quay` - it's built, cached, and also pushed to quay.io. Requirements for quay would be to be logged in to your runtime to authenticate against quay.io. The images are named using `quay.io/<quay_namespace>/operator-workshop-lab-guide-<workshop_name>`.
3. (optional) - Quay namespace tag. By default, this is `jduncan` (makes it easier for the author). You can specify a different quay namespace using this parameter.

## run.sh

This script runs containers in various environments. It's useful for testing, QA, or even running lab guides in environments that lack OpenShift or kubernetes. It takes up to 3 parameters.

1. Name of the workshop to build. This needs to correspond with the directory name for your workshop in the `workshops` directory.
2. Build target - `local`, `start`, or `stop`
  * `local` - Runs the named workshop, using only the local container cache. This is useful when testing out a new build that hasn't been pushed to quay.io yet.
  * `start` - Runs the named workshop, but pulls the latest image from quay.io and uses that as the image to run the container from
  * `stop` - Stops the specified workshop
3. (optional) - container host port. If not specified, the lab guide serves on port 8080. This is useful if you want to run multiple lab guides simultaneously or if you need to not use the standard port. 
