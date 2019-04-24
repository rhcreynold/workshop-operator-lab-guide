.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==================
Deploying Site
==================
Overview
`````````

We now have Site A and Site B, each site consists of 2 rhel virtual machines, for a total of 4 rhel virtual machines.  In this lab we are going to
deploy a containerized simple web application (from an Ansible Role) on two different hosts. This will host a simple
website.

Let first modify the ``hosts`` file and add the correct ip addresses for our web servers.

.. parsed-literal::
  [gogs]
  |control_public_ip|

  [siteA]
  |node_1_ip|
  |node_2_ip|

  [siteB]
  |node_3_ip|
  |node_4_ip|

  Now let us create the Ansible role structure, but first we need to get into the right folder.

  .. code-block:: bash

    $ cd ~/devops-workshop
    $ cd roles

  Now it is time to create the Ansible Role structure

  .. code-block:: bash

    $ ansible-galaxy init apache-simple

  Now let us add some default variables to your role in `roles/apache-simple/defaults/main.yml.`
  This will put a simple message on the index.html page.

  .. code-block:: yaml

    ---
    # defaults file for apache-simple
    apache_test_message: This is a test message being served by {{ running_env }}
    apache_webserver_port: 80


Next let create the main tasks to generate the config files that we are building into the container.


    .. parsed-literal::

      $ cd /home/|student_name|/devops-workshop/
      $ vim roles/apache-simple/tasks/main.yml


    .. parsed-literal::

        ---
      # tasks file for apache

      - name: Ensure latest httpd.conf file is present for Container
        template:
          src: httpd.conf.j2
          dest: /home/|student_name|/devops-workshop/httpd.conf

      - name: Ensure latest index.html file is present for Container
        template:
          src: index.html.j2
          dest: /home/|student_name|/devops-workshop/index.html


  Download a couple of templates into ``roles/apache-simple/templates/``

  .. code-block:: yaml

    $ mkdir -p ~/apache-role/roles/apache-simple/templates/
    $ cd ~/apache-role/roles/apache-simple/templates/
    $ curl -O https://raw.githubusercontent.com/ansible/lightbulb/master/examples/apache-role/roles/apache-simple/templates/httpd.conf.j2
    $ curl -O https://raw.githubusercontent.com/ansible/lightbulb/master/examples/apache-role/roles/apache-simple/templates/index.html.j2

Lets take a look at the DockerFile to build the container.  This is going to pull a rhel
container that has apache installed.  From there we are going to add the config files `index.html` and `httpd.conf` to the
container.

.. parsed-literal::

  # Pull the rhel image from the local registry
  FROM rhscl/httpd-24-rhel7
  USER root

  MAINTAINER |student_name|

  # Add configuration file
  COPY httpd.conf /etc/httpd/conf
  COPY index.html /var/www/html/
  RUN chown -R apache:apache /var/www/html
  EXPOSE 80


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
    vars:
       - running_env: "dev"
    roles:
      - apache-simple

    tasks:

     - name: build a new docker image
       command: "docker build -t |control_public_ip|:5000/student1/apache-simple ."

     - name: Tag and push to local registry
       docker_image:
          name: apache-simple
          repository: |control_public_ip|:5000/student1
          tag: latest
          push: no

     - name: Manually push the image
       command: "docker push |control_public_ip|:5000/student1/apache-simple"


Now its time to build the container:

.. code-block:  bash

    $ ansible-playbook -i hosts build-apache-simple-container.yml

Now there should be a `index.html` and a `httpd.conf` in /home/|student_name|/devops-workshop/.

Next step is to deploy the containers to site B.  We are going to create a simple playbook to do just that.

.. code-block:: bash

  $ vim deploy-apache-simple-container.yml

Inside that file should have the following:

.. parsed-literal::

  ---
  - name: launch apache containers on site2 nodes
  hosts: all
  become: yes

  tasks:
    - name: launch apache-simple container on {{ running_env }} nodes
      docker_container:
        name: apache-simple
        image: |control_public_ip|:5000/student1/apache-simple
        pull: true
        ports:
          - "8080:80"
        restart_policy: always

so let's go ahead and run this on the dev nodes only:

.. code-block:: bash

  $ ansible-playbook --limit dev -i hosts deploy-apache-simple-container.yml

Assuming everything ran you can test each node with the curl command.

.. parsed-literal::

  $ curl http://|node_1_ip|:8080
  $ curl http://|node_2_ip|:8080
