.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>
.. _docs admin: jduncan@redhat.com

===========================
Setting up Artifact Control
===========================

Overview
`````````

In this lab you'll configure your control host to serve your playbooks and other content for the rest of today's lab. We'll be using `GOGS <https://gogs.io/>`__ deployed in a container for this. Our tasks for this lab are to:

1. Write a playbook to deploy GOGS on your control host
2. Deploy GOGS and confirm it's functioning properly
3. Deploy a container registry to manage container images

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
  [control]
  |control_public_ip|

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

  $ tree gogs
  gogs
  ├── defaults
  │   └── main.yml
  ├── files
  ├── handlers
  │   └── main.yml
  ├── meta
  │   └── main.yml
  ├── README.md
  ├── tasks
  │   └── main.yml
  ├── templates
  ├── tests
  │   ├── inventory
  │   └── test.yml
  └── vars
      └── main.yml

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
      exposed_ports:
        - "3306"
      restart_policy: always

Next, well create a role to manage our container registry deployment

Creating a registry role
`````````````````````````

You'll be deploying the `Docker v2 registry <https://hub.docker.com/_/registry>`__ on your control node and serving content on port 5000. To start, we'll create a new role inside ``playbook/roles``, and use ``ansible-galaxy`` to start a role named ``registry``.

.. code-block::

  $ cd ~/playbook/roles
  $ ansible-galaxy init registry
  - registry was created successfully
  $ tree registry
  registry
  ├── defaults
  │   └── main.yml
  ├── files
  ├── handlers
  │   └── main.yml
  ├── meta
  │   └── main.yml
  ├── README.md
  ├── tasks
  │   └── main.yml
  ├── templates
  ├── tests
  │   ├── inventory
  │   └── test.yml
  └── vars
      └── main.yml

  8 directories, 8 files

In your new registry role, add the following content to ``tasks/main.yml``.

.. code-block:: yaml

  ---
  # tasks file for registry
  - name: pull the registry image
    docker_image:
      name: registry
      state: present

  - name: deploy the registry container
    docker_container:
      name: registry
      image: registry
      ports:
        - "5000:5000"
      restart_policy: always

Writing your artifact control playbook
````````````````````````````````````````

With your roles in place, you're ready to deploy GOGS, MariaDB, and the container registry on your control node. To do this, your playbook will need to reference the roles you just created. In your ``playbook`` directory, create a file named ``deploy_artifacts.yml`` with the following contents.

.. code-block:: yaml 

  - name: deploy GOGS MariaDB and container registry
    gather_facts: false
    become: yes
    hosts: control
    roles:
      - gogs
      - registry

Once complete, run ``ansible-playbook`` referencing your inventory and the playbook you just created.

.. code-block::

  $ ansible-playbook -i hosts deploy_artifacts.yml -k
  SSH password:

  PLAY [deploy GOGS MariaDB and container registry] *****************************************************************

  TASK [gogs : install docker-py requirements] *****************************************************************
  ok: [3.91.13.13]

  TASK [gogs : pull the GOGS and MariaDB images] *****************************************************************
  changed: [3.91.13.13] => (item=gogs/gogs)
  changed: [3.91.13.13] => (item=mariadb)

  TASK [gogs : start the GOGS container] *****************************************************************
  changed: [3.91.13.13]

  TASK [gogs : start the MariaDB container] *****************************************************************
  changed: [3.91.13.13]

  TASK [registry : pull the registry image] *****************************************************************
  changed: [3.91.13.13]

  TASK [registry : deploy the registry container] *****************************************************************
  changed: [3.91.13.13]

  PLAY RECAP *****************************************************************
  3.91.13.13                 : ok=6    changed=5    unreachable=0    failed=0

Before we can use GOGS to house our source code, we need to configure it to connect to the MariaDB container.

Configuring GOGS
`````````````````

The GOGS UI is listening at |control_public_ip|:8081. The configuration is done using a web wizard. You'll need to configure a few options in this wizard to get going.

Connecting to MariaDB
``````````````````````

First, we'll tell GOGS how to connect to the MariaDB container. For this configuration, we'll use the IP address assigned to the MariaDB container by the container runtime. To find this IP address, we'll query the address directly. First we'll need the container ID for the MariaDB container

.. code-block::

  # docker ps | grep mariadb
  4951ffc5110b        mariadb                                                          "docker-entrypoint..."   7 minutes ago       Up 7 minutes        3306/tcp                                        mariadb

In our example, the container ID is ``4951ffc5110b``.

With this information, we can query the container runtime to get it's IP address.

.. code-block::

  # docker inspect --format '{{ .NetworkSettings.IPAddress }}' 4951ffc5110b
  172.17.0.4

Our container's IP address is ``172.17.0.4``.

.. figure:: _static/images/gogs_config_1.png

   Database connection options for GOGS

With this section complete, we'll wrap up the other configuration options.

Configuring GOGS URLs
```````````````````````

GOGS needs to know the URLs to use for cloning repositories and to host its application. Replace the instances of ``localhost`` in the *Domain* and *Application URL* fields with |control_public_ip|. Additionally, the port number for *Application URL* needs to be ``8081``.

.. figure:: _static/images/gogs_config_2.png

This completes the GOGS configuration. Next, we'll register your user.

Setting up a GOGS user
```````````````````````

Once the configuration is complete you'll be forwarded to the GOGS login page. Click the *Sign up now.* link in the bottom of the UI square.

.. figure:: _static/images/gogs_login.png

This takes you to the registration page. Use your student name, |student_name| for your login, and ``redhat`` for your password. Email is a required field, but we're not going to configure email notifications so any fake email address is fine. The final field is a Captcha field. Fill them out and click *Create New Account*.

.. figure:: _static/images/gogs_register.png

You'll be returned to the login page. Log in with your |student_name| user with the password of ``redhat``. You'll see your dashboard page after logging in.

.. figure:: _static/images/gogs_dash.png

GOGS is now configured to house all of your repositories for the rest of the lab. Let's move on to the next lab where we'll configure our first load-balanced site.

.. admonition:: What if I need to reset?

  For this workshop, GOGS, MariaDB, and the container registry are not using persistent storage. That means if you stop these containers and restart them, you'll essentially be starting from scratch with configuring GOGS. This can be helpful, but be careful!
