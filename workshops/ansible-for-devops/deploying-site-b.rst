.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: jduncan@redhat.com

===========================
Deploying your dev cluster
===========================
Overview
`````````

We have gone ahead and stood up two additional Red Hat Enterprise Linux hosts for you.  In this lab we are going to
deploy a containerized simple web application (from an Ansible Role) on two different hosts. This will host a simple
website.  This is an integration of the last role that we made in Deploying site a.

Modify the hosts file
`````````````````````

Let first modify the ``hosts`` file and add the correct ip addresses for our web servers.

.. parsed-literal::
  [gogs]
  |control_public_ip|

  [registry]
  |control_public_ip|

  [dev]
  |node_1_ip|
  |node_2_ip|

  [prod]
  |node_3_ip|
  |node_4_ip|

Ok so now we have our inventory let use the same role to build the same website as last time but
in a container. We are going to build a playbook that leverages the role that we previous created.

Let modify the main playbook inside the role from site A.  This is going to give us the flexibility of using the same
Ansible code to deploy the same content.  Notice that we have added tags, read more about Ansible tags `here <https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html/>`__

Modify our Apache Role
`````````````````````

.. parsed-literal::

  $ cd /home/|student_name|/devops-workshop/
  $ vim roles/apache-simple/tasks/main.yml


.. parsed-literal::

    ---
  # tasks file for apache
  - name: Ensure httpd packages are present
    yum:
      name: "{{ item }}"
      state: present
    with_items: "{{ httpd_packages }}"
    notify: restart-apache-service
    tags:
       - rpm

  - name: Ensure latest httpd.conf file is present for RPM
    template:
      src: httpd.conf.j2
      dest: /etc/httpd/conf/httpd.conf
    notify: restart-apache-service
    tags:
       - rpm

  - name: Ensure latest httpd.conf file is present for Container
    template:
      src: httpd.conf.j2
      dest: /home/|student_name|/devops-workshop/httpd.conf
    tags:
       - container

  - name: Ensure latest index.html file is present for RPM
    template:
      src: index.html.j2
      dest: /var/www/html/index.html
    tags:
       - rpm

  - name: Ensure latest index.html file is present for Container
    template:
      src: index.html.j2
      dest: /home/|student_name|/devops-workshop/index.html
    tags:
       - container

  - name: Ensure httpd service is started and enabled
    service:
      name: httpd
      state: started
      enabled: yes
    tags:
       - rpm

Now that we have added tags, lets take a look at the DockerFile to build the container.  This is going to pull a rhel
container that has apache installed.  From there we are going to add the config files `index.html` and `httpd.conf` to the
container.  This will server the exact same site as the rpm version that we deployed earlier.

Containers
```````````

Creating the Dockerfile
^^^^^^^^^^^^^^^^^^^^^^^

.. parsed-literal::

  # Pull the rhel image from the local registry
  FROM rhscl/httpd-24-rhel7
  USER root

  MAINTAINER |student_name|

  # Add configuration file
  ADD httpd.conf /etc/httpd/conf
  ADD index.html /var/www/html/
  RUN chown -R apache:apache /var/www/html
  EXPOSE 8080


Playbook to build the container and push it
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now we can create a Ansible playbook to build the container and push it into the registry that we created earlier.

.. code-block:: bash

  $ vim build-apache-simple-container.yml

This will have the following content.  Note how we are using the container tag, this playbook can be used for the rpm deployment
or the container based deployment based about using tags.

.. parsed-literal::

  ---
  - name: Ensure apache is installed and started via role
    hosts: localhost
    become: yes
    roles:
      - apache-simple

    tasks:

     - name: build a new docker image
       command: "docker build -t apache-simple ."
       tags:
          - container

     - name: Tag and push to registry
       docker_image:
         name: apache-simple
         repository: |control_public_ip|:5000/student1/apache-simple
         push: yes
         source: local
         tag: latest
       tags:
          - container


Now its time to build the container:

.. code-block:  bash

    $ ansible-playbook -i hosts build-apache-simple-container.yml

Now there should be a `index.html` and a `httpd.conf` in /home/|student_name|/devops-workshop/.

Playbook to deploy the container
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Next you'll deploy a container-based version of your application to your dev environment.  In this lab you'll do that using Ansible as well. First, you'll need to add a ``dev`` group to ``~/playbook/hosts``.



.. code-block:: bash

  $ vim deploy-apache-simple-container.yml

Inside that file should have the following:

.. parsed-literal::

  ---
  - name: launch apache containers on site2 nodes
    hosts: dev
    become: yes

    tasks:
      - name: launch apache-simple container on siteb nodes
        docker_container:
          name: apache-simple
          image: |control_public_ip|:5000/student1/apache-simple
          ports:
            - "8080:80"
          restart_policy: always

so let's go ahead and run this:

.. code-block:: bash

  $ ansible-playbook -i hosts deploy-apache-simple-container.yml


OUTPUT GOES HERE

Assuming everything ran you can test each node with the curl command.

.. parsed-literal::

  $ curl http://|node_3_ip|:8080
  $ curl http://|node_4_ip|:8080
