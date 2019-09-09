.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: jduncan@redhat.com

===========================
Deploying to dev
===========================
Overview
`````````

Just like production, your development environment is pre-provisioned and secured at this point. In this lab you're deploying a containerized version of your production web application for your theoretical developers to continue developing for their shiny new container platform.

To begin, add a ``dev`` group to ``~/playbook/hosts``.

Modifying your inventory
``````````````````````````
After adding your ``dev`` group, your version of ``~/playbook/hosts`` should look like this example:

.. parsed-literal::

  [nodes]
  |node_1_ip|
  |node_2_ip|
  |node_3_ip|
  |node_4_ip|

  [gogs]
  |control_public_ip|

  [registry]
  |control_public_ip|

  [prod]
  |node_3_ip|
  |node_4_ip|

  [dev]
  |node_1_ip|
  |node_2_ip|

One of the key Anisble best practices is to :dry:`re-use code whenever possible<>` with *Don't Repeat Yourself (DRY)* principles. DRY makes maintenance easier and also makes your environments more consistent. With that in mind, you'll create a playbook that leverages the role you created to deploy to production instead of creating an entirely new role.

Modify the main playbook inside the role from site A.  This is going to give us the flexibility of using the same Ansible code to deploy the same content.  Notice the newly added :ansible_docs:`playbook tags<user_guide/playbooks_tags.html>`.

Adding tags to your Apache role
`````````````````````````````````

First, you'll be editing the tasks in ``~/playbook/roles/apache-simple``.

.. parsed-literal::

  $ cd ~/playbook
  $ vim roles/apache-simple/tasks/main.yml

You need to add Ansible tags to your tasks to distinguish whether the tasks will be executed when deploying rpms or when creating a container image.

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
      dest: /home/|student_name|/playbook/apache-simple/httpd.conf
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
      dest: /home/|student_name|/playbook/apache-simple/index.html
    tags:
       - container

  - name: Ensure httpd service is started and enabled
    service:
      name: httpd
      state: started
      enabled: yes
    tags:
       - rpm

With the proper tags in place, you need to create a Dockerfile to build your custom httpd container. Your container's base image will already have ``httpd`` installed. Your Dockerfile only needs to add the custom index page and ``httpd`` configuration to the image in the proper location.

Creating your Dockerfile
`````````````````````````

Create ``~/playbook/apache-simple/Dockerfile`` with the following content:

.. parsed-literal::

  FROM rhscl/httpd-24-rhel7
  USER root
  MAINTAINER |student_name|
  ADD httpd.conf /etc/httpd/conf
  ADD index.html /var/www/html/
  RUN chown -R apache:apache /var/www/html
  EXPOSE 8080

With this done, you need to build your new container image and push it into your container registry.

Creating and pushing your container image
```````````````````````````````````````````

The next step is to create a new playbook that uses your newly versioned ``apache-simple`` role to build your container image and push it to your container image.

.. code-block:: bash

  $ cd ~/playbook
  $ vim apache-simple-container-build.yml

Add the following content to your new playbook. Note you're adding the ``container`` tag to these tasks, so they'll be executed only when you're building a container image. They'll be ignored when deploying your application via rpms.

.. parsed-literal::

  ---
  - name: Ensure apache is installed and started via role
    hosts: localhost
    become: yes
    roles:
      - apache-simple

     - name: build a new docker image
       command: "docker build -t apache-simple /home/|student_name|/playbook/apache-simple"
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

With your tasks added, run the playbook using ``ansible-playbook``, specifying that only tasks with the ``container`` tag are executed.

.. code-block:  bash

  $ cd ~/playbook
  $ ansible-playbook -i hosts apache-simple-container-build.yml

Your custom httpd image is now in your container registry. Your next playbook will deploy your application to your development nodes.

Deploying your dev environment
````````````````````````````````````````

The next step in this workflow is to write the playbook that deploys your development environent. Create ``~/playbook/apache-simple-container-deploy.yml``

.. code-block:: bash

  $ cd ~/playbook
  $ vim apache-simple-container-deploy.yml

and add the following content:

.. admonition:: Taking care of container-specific dependencies

  There are three tasks in this playbook that handle dependencies for allowing the ``docker_container`` module to run on your dev nodes and to allow your dev nodes to access your container registry via http.

.. parsed-literal::

  ---
  - name: launch apache containers on dev nodes
    hosts: dev
    become: yes

    tasks:
    - name: install docker-py prerequisites
      pip:
        name: docker-py

    - name: add insecure registry option for dev nodes
      lineinfile:
        path: /etc/sysconfig/docker
        regexp: '^OPTIONS='
        line: OPTIONS='--insecure-registry=\ |control_public_ip|:5000 --selinux-enabled --log-driver=journald --signature-verification=false'

    - name: restart docker service
      service:
        name: docker
        state: restarted

    - name: launch apache-simple container on dev nodes
      docker_container:
        name: apache-simple
        image: |control_public_ip|:5000/|student_name|/apache-simple
        ports:
          - "8080:80"
        restart_policy: always

With this complete, commit your changes to source control and run the playbook to deploy your development environment.

.. code-block:: bash

  $ git add -A
  $ git commit -a -m 'dev environment ready to deploy'
  $ git push origin master
  $ cd ~/playbook
  $ ansible-playbook -i hosts apache-simple-container-deploy.yml

With a successful completion, confirm your dev cluster is functional by accessing each node.

.. parsed-literal::

  $ curl \http://|node_3_ip|:8080
  $ curl \http://|node_4_ip|:8080

Summary
````````

Just like a lot of actual environments represented in this workshop today, production is deployed in a "tradtional" manner and containers are used for development with an eye toward a future production methodology. Can you see where the extra work you've done to containerize your web application will quickly provide a solid ROI? 
