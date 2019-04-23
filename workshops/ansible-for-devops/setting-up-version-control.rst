.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>
.. _docs admin: jduncan@redhat.com

===========================
Setting up Version Control
===========================

Overview
`````````

In this lab you'll configure your control host to serve your playbooks and other content for the rest of today's lab. We'll be using `GOGS <https://gogs.io/>`__ deployed in a container for this. Our tasks for this lab are to:

1. Write a playbook to deploy GOGS on your control host
2. Deploy GOGS and confirm it's functioning properly

.. admonition:: Do I need to configure docker?!

  Your control host already has all the dependencies to run docker containers. That's because this lab guide is already running on your control host inside a container!

Let's get started.

Creating an initial inventory
``````````````````````````````

Ansible best practices include using inventory groups consistently. This makes your playbooks more portable. When your environment changes, only the inventory needs to be updated. Your roles and playbooks don't need to be edited.

.. admonition:: Why is this important?

  This allows content you create in this workshop to be used by simply using a different inventory.

Let's create your initial inventory with a ``gogs`` group. In your home directory, /home/|student_name|, create a directory named ``devops-workshop``.

.. code-block:: bash

  $ mkdir ~/devops-workshop
  $ cd devops-workshop

Next, in that directory, create a file named ``hosts`` with the following content:

.. parsed-literal::
  [gogs]
  |private_ip|

Next, we'll create an `ansible role <https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html>`__ to apply to our GOGS group.

Creating a GOGS role
`````````````````````
Ansible roles should live in your playbook project inside a directory named ``roles``. Go ahead and create that directory.

.. code-block:: bash

  $ cd ~/devops-workshop
  $ mkdir roles
  $ cd roles

As we stated in the initial presentation, we're going to do our best to follow Ansible best practices in all of these labs. One of the key best practices is to use roles in (practically) every situation. Deploying GOGS will be no different. To create a role, we use the ``ansible-galaxy`` command.

.. code-block:: bash

  $ ansible-galaxy init gogs

This creates the prescriptive directory structure for your ansible role.

.. code-block:: bash

  $ ll gogs
  total 4
  drwxr-xr-x. 2 root root   22 Mar 16 06:52 defaults
  drwxr-xr-x. 2 root root    6 Mar 16 06:52 files
  drwxr-xr-x. 2 root root   22 Mar 16 06:52 handlers
  drwxr-xr-x. 2 root root   22 Mar 16 06:52 meta
  -rw-r--r--. 1 root root 1328 Mar 16 06:52 README.md
  drwxr-xr-x. 2 root root   22 Mar 16 06:52 tasks
  drwxr-xr-x. 2 root root    6 Mar 16 06:52 templates
  drwxr-xr-x. 2 root root   39 Mar 16 06:52 tests
  drwxr-xr-x. 2 root root   22 Mar 16 06:52 vars

This completes the basic infrastructure we'll need. Now, it's time to write some Ansible by creating our first role.

Creating GOGS role tasks
^^^^^^^^^^^^^^^^^^^^^^^^^

The tasks to deploy GOGS need to accomplish these tasks:

* Pull down a pre-defined GOGS container image
* Deploy the container on to the control host using the proper host port

In your GOGS role, add the following content to your ``tasks/main.yml`` file:

.. code-block:: yaml

  ---
  # tasks file for gogs
  - name: install docker-py requirements
    pip:
      name: docker-py
      state: present
      extra_args: --trusted-host pypi.org --trusted-host files.pythonhosted.org

  - name: pull the GOGS and MariaDB images
    docker_image:
      name: "{{ item }}"
      state: present
      with_items:
        - gogs/gogs
        - mariadb

  - name: start the GOGS container
    docker_container:
      name: gogs
      image: gogs/gogs
      ports:
        - "8081:3000"
        - "10022:22"
      restart_policy: always

  - name: start the MariaDB container
    docker_container:
      name: mariadb
      image: mariadb
      env:
        MYSQL_ROOT_PASSWORD: redhat
        MYSQL_DATABASE: gogs
        MYSQL_USER: gogs
        MYSQL_PASSWORD: redhat
      ports:
        - "3306:3306"


Writing your GOGS playbook
```````````````````````````

.. code-block:: yaml

  ...
  - name: deploy GOGS to control host
    hosts: control
    - tasks:

      name: pull GOGS image

Configuring GOGS
`````````````````
