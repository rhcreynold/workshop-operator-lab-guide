.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

===========================
Deploying to Site-B
===========================
Overview
`````````

Just like Site-A, your Site-B environment is pre-provisioned and secured at this point. In this lab you're deploying a containerized version of your Site-A web application for your theoretical developers to continue developing for their shiny new container platform.

To begin, add a ``dev`` group to ``~/ansible-for-devops-workshop/hosts``.

Modifying your inventory
``````````````````````````
After adding your ``siteb`` group, your version of ``~/ansible-for-devops-workshop/hosts`` should look like this example:

.. parsed-literal::

  [nodes]
  |node_1_ip|
  |node_2_ip|
  |node_3_ip|
  |node_4_ip|

  [sitea]
  |node_3_ip|
  |node_4_ip|

  [siteb]
  |node_1_ip|
  |node_2_ip|

One of the key Anisble best practices is to :dry:`re-use code whenever possible<>` with *Don't Repeat Yourself (DRY)* principles. DRY makes maintenance easier and also makes your environments more consistent. With that in mind, you'll create a playbook that leverages the role you created to deploy to Site-A instead of creating an entirely new role.

Modify the main playbook inside the role from site A.  This is going to give us the flexibility of using the same Ansible code to deploy the same content.  Notice the newly added :ansible_docs:`playbook tags<user_guide/playbooks_tags.html>`.

Adding tags to your Apache role
`````````````````````````````````

If you have a large playbook, it may become useful to be able to run only a specific part of it rather than running everything in the playbook. Ansible supports a “tags:” attribute for this reason.

First, you'll be editing the tasks in ``~/ansible-for-devops-workshop/roles/apache-simple``.

.. code-block:: bash

  $ cd ~/ansible-for-devops-workshop
  $ vim ~/ansible-for-devops-workshop/roles/apache-simple/tasks/main.yml

You need to add Ansible tags to your tasks to distinguish whether the tasks will be executed when deploying rpms or when creating a container image.

.. code-block:: yaml

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
      dest: /home/|student_name|/ansible-for-devops-workshop/siteb/etc/httpd/conf/httpd.conf
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
      dest: /home/|student_name|/ansible-for-devops-workshop/siteb/var/www/html/index.html
    tags:
       - container

  - name: Ensure httpd service is started and enabled
    service:
      name: httpd
      state: started
      enabled: yes
    tags:
       - rpm

With the proper tags in place, you need to create a ``Dockerfile`` to build your custom httpd container. Your container's base image will already have ``httpd`` installed. Your ``Dockerfile`` only needs to add the custom index page and ``httpd`` configuration to the image in the proper location.


Creating your Dockerfile and Building the needed files
```````````````````````````````````````````````````````
We are also going to create two folders, one for the Ansible generated ``httpd.conf`` file and one for the ``index.html`` file. These will be used by Quay.io Build system to create the container from the ``Dockerfile``.
Create ``~/ansible-for-devops-workshop/siteb/Dockerfile`` with the following content:


.. code-block:: bash

  $ mkdir ~/ansible-for-devops-workshop/siteb
  $ mkdir -p ~/ansible-for-devops-workshop/siteb/etc/httpd/conf
  $ mkdir -p ~/ansible-for-devops-workshop/siteb/var/www/html
  $ vim ~/ansible-for-devops-workshop/siteb/Dockerfile

.. parsed-literal::

  FROM registry.access.redhat.com/rhscl/httpd-24-rhel7
  USER root
  MAINTAINER |student_name|
  ADD ./etc/httpd/conf/httpd.conf /etc/httpd/conf
  ADD ./var/www/html/index.html /var/www/html/
  RUN chown -R apache:apache /var/www/html
  EXPOSE 8080

Now lets create a Site-B playbook that generates the needed ``index.html`` and ``httpd.conf``.

.. code-block:: bash

  $ vim ~/ansible-for-devops-workshop/siteb-config-build.yml

And add this content to the file:

.. code-block:: yaml

  ---
  - name: Deploy site web infrastructure
    hosts: localhost
    become: yes

    roles:
      - apache-simple


.. admonition:: Why localhost?

    We are using Ansible to generate files on the control node with the variables that we set.  We will then push these files into our repository.  This gives us a repeatable, scalable and version controlled manor for generation of configs and other files.


Go ahead and run it:

.. code-block:: bash

  $ ansible-playbook siteb-config-build.yml --tags container

The Ansible generated config files are located in ``~ansible-for-devops-workshop/siteb/``. Take a look and see what they look like!

With this done, we will need to add, commit and push the files to our Git repo.  Below is the output from the commit:

.. parsed-literal::

  Enumerating objects: 11, done.
  Counting objects: 100% (11/11), done.
  Delta compression using up to 12 threads
  Compressing objects: 100% (4/4), done.
  Writing objects: 100% (6/6), 483 bytes | 483.00 KiB/s, done.
  Total 6 (delta 3), reused 0 (delta 0)
  remote: Resolving deltas: 100% (3/3), completed with 3 local objects.
  To https://github.com/rhcreynold/ansible-for-devops-workshop.git
     41bf866..d2bcf5e  master -> master


Creating Building and Pushing your container image
``````````````````````````````````````````````````

The next step is to link :quay:`quay.io<>` container registry to your :github:`github.com<>` repo and create the container build process.

Go back to your Quay.io account :quay:`quay.io<>` and select the ``Builds`` icon, you may need to click on the ``ansible-for-devops-siteb`` Repository.  From there we are going to select ``Create a Build Trigger`` via the Github Repository Push.

Select the Organization that you created and select Continue, next we will select the ``ansibe-for-devops-workshop`` repository and hit continue.

For the Trigger, leave the ``default`` option and hit continue.

On the ``Select Dockerfile`` page, click the dropdown arrow and select ``/siteb/Dockerfile`` and select continue.

For the context, you must select ``/siteb``.  If not then the build will fail.  The context refers to where is path that it should start in when referencing things.  In our ``Dockerfile`` we added two files, the ``index.html`` and the ``httpd.conf``. We referenced them as a relative path and not the absolute path, this is why the context location is important.

We will not be selecting a robot account, so hit continue and the "Ready to Go" will appear, from there we can select ``Continue`` and this will complete the Build Trigger.

Back on the build page, click the gear icon and next to your newly created ``Build Triggers``.   Select ``Run Trigger Now`` and for Branch/Tag select ``master``, then hit ``Start Build``.

In the ``Build History`` above you will now see a build that is running, click the ``Build ID`` and watch your container being built!!

Your custom httpd image is now in your :quay:`quay.io<>` container registry. Your next playbook will deploy your application to your Site-B nodes.

Deploying your Site-B environment
````````````````````````````````````````

The next step in this workflow is to write the playbook that deploys your Site-B environment. Create ``~/ansible-for-devops-workshop/siteb-apache-simple-container-deploy.yml``

.. code-block:: bash

  $ cd ~/ansible-for-devops-workshop
  $ vim siteb-apache-simple-container-deploy.yml

.. admonition:: Taking care of container-specific dependencies

  There is a single task in this playbook that handle dependencies for allowing the ``docker_container`` module to run on your dev nodes.

and add the following content:

.. code-block:: yaml

  ---
  - name: Deploy Site-B
    hosts: siteb
    become: yes

    tasks:
    - name: install docker preqequisities
      pip:
        name: docker

    - name: launch the apache-simple container on the site-b nodes
      docker_container:
        name: apache-simple
        image: quay.io/|student_name|/ansible-for-devops-siteb
        ports:
          - "8080:8080"

With this complete, commit your changes to source control and run the playbook to deploy your Site-B environment.

.. code-block:: bash

  $ git add -A
  $ git commit -a -m 'dev environment ready to deploy'
  $ git push origin master
  $ cd ~/ansible-for-devops-workshop
  $ ansible-playbook -k -i hosts siteb-apache-simple-container-deploy.yml

With a successful completion, confirm your dev cluster is functional by accessing each node.

.. parsed-literal::

  $ curl \http://|node_3_ip|:8080
  $ curl \http://|node_4_ip|:8080

Summary
````````

Just like a lot of actual environments represented in this workshop today, Site-A is deployed in a RPM based deployment and containers are used for Site-B.
