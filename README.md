# Workshop Operator Lab Guide

The goal of this project is to be self-documenting. We maintain most of the documentation in one of the lab guide projects. Getting it to work means you have the prerequisites and requirements taken care of.

## Prerequisites

* docker or podman on the host to view the documentation
* sudo access

## Deploying a workshop

There are currently 3 workshops in this repository:

* example-workshop: The documentation for more advanced features as well as contributing to this project.
* better-together: The Ops lab guide for the Better Together: Ansible and OpenShift workshop series.
* ansible-for-devops: The revamped, container-based Ansible Essentials workshop content.

### Starting a workshop:

```
$ sudo hack/run.sh <WORKSHOP-NAME> start
```

And that's it. The workshop guide your specified is running on your server on port 8080.

### Running multiple workshops at once, or running on a port other than 8080:

```
$ sudo hack/run.sh <WORKSHOP-NAME> start <PORT>
```

*note: only one copy of a single workshop works right now. You can run multiple different workshops on different ports, but only one of each.*

### Stopping a workshop:

```
$ sudo hack/run.sh <WORKSHOP-NAME> stop
```
