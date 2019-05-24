# Workshop Operator Lab Guide

The goal of this project is to be self-documenting. We maintain most of the documentation in one of the lab guide projects. Getting it to work means you have the prerequisites and requirements taken care of.

## Prerequisites

* docker or podman on the host to view the documentation
* sudo access

## Deploying the documentation

The documentation for this software is maintained in the `example-project` as a sphinx-docs project. To deploy and view it, check out this repository and run:

```
$ sudo hack/run.sh example-workshop start
```

And that's it. The project documentation is running on your server on port 8080. Happy contributing!
