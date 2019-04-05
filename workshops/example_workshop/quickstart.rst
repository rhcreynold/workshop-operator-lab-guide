.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>
.. _docs admin: jduncan@redhat.com

=============
Quickstart
=============

The basics of working with the lab guide project, and spinning up a local copy for customer demos and smaller workshops. The first step is to always check out a local copy of the :github_url:`Github project <workshop-operator-lab-guide>`. We'll be using the ``example_workshop`` project (which is also this howto guide).

.. code-block:: bash

  $ git clone git@github.com:jduncan-rva/workshop-operator-lab-guide.git

Requirements
`````````````

As much as we love buildah and podman,  we understand that this will often be run on Mac laptops. For that reasons, for right now, we're using Docker as the default container runtime.

.. admonition:: What about buildah?!

  All of the automation will of course work on Linux as well, and converting it to use podman should be trivial if anything needs to be done at all.

Building a local copy of your workshop guide
`````````````````````````````````````````````

In the root directory of the repository is ``build.sh``. This script makes it easy to build a container image that houses your project's lab guide. The usuage is simple:

.. code-block:: bash

  $ ./build.sh example_workshop local

The ``local`` directive tells the script to build a local container image.

.. admonition:: Other build targets

  ``build.sh`` also has a ``quay`` build target that is used as part of the CI/CD workflow. It requires a few additional variables:

  * ``QUAY_PROEJCT`` - The quay.io project you want to upload to. This variable in ``build.sh`` is also used for the local build tag.
  * ``DOCKER_USERNAME`` - Your quay.io username
  * ``DOCKER_PASSWORD`` - Your quay.io password

  For travis-ci, the usernames and passwords are encrypted and aren't visible in the job output.

Running a local copy of your lab guide
```````````````````````````````````````

In the root directory of the repository is ``run.sh``. This is used to start and stop your lab guide container.

.. code-block:: bash
  :caption: 'This command starts your lab guide locally'

  $ ./run.sh example_workshop local
  No lab guides are currently running
  Preparing new lab guide for example_workshop
  example_workshop is running as container ID 05b2fd52306d and is avaiable at http://localhost:8080

Stopping a local copy of your lab guide
````````````````````````````````````````

The same ``run.sh`` script is used to cleanly stop your lab guides.

.. code-block:: bash
  :caption: 'This command stops your lab guide locally'

  $ ./run.sh example_workshop stop
  Stopping example_workshop container ID a0fcb61cc934
  Lab Guide for example_workshop stopped

Do you have to use the helper scripts?
```````````````````````````````````````

You can of course do all of this manually using your container runtime commands. The helper scripts allow you to create and run multiple labs guides simultaneously when you need to right on your laptop. They also clean up after themselves nicely.
