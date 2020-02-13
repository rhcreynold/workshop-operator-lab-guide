.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

=================================
Load-balancing your clusters
=================================

In exercise we're going to deploy an :nginx:`nginx<>` reverse proxy and load balancer. This proxy will take incoming http requests over port 8081
and forward them to one of the 4 web servers that we have deployed. Like most of your other services in today's workshop, you'll be containerizing nginx.


Modifying your inventory
``````````````````````````

Like your other services, your load balancer needs a group in your Ansible inventory at ``~/ansible-for-devops-workshop/hosts``. Add a group named ``lb`` with the IP address of your control node.

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

  [lb]
  |control_public_ip|

With your inventory group created, it's time to move on to customizing your nginx configuration and building a custom container image.

Creating the nginx container image
-----------------------------------

Nginx has a built-in module that acts as a reverse proxy load balancer named ``proxy_pass``. You'll need to configure that module as well as an ``upstream`` server group for both site-a and site-b in your ``default.conf`` configuration file at ``/etc/nginx/conf.d/default.conf``.

Setting up nginx.conf
```````````````````````

The first step to create your customized nginx container is to create the proper configuration file.

Create a directory named ``~/ansible-for-devops-workshop/nginx-lb`` on your control node. Inside that directory create a file named ``default.conf`` with the following contents:

.. code-block:: bash

  $ cd ~/ansible-for-devops-workshop
  $ mkdir -p ~/ansible-for-devops-workshop/nginx-lb/etc/nginx/conf.d/
  $ vim nginx-lb/etc/nginx/conf.d/default.conf

.. parsed-literal::

  upstream backend {
   	server |node_1_ip|:8080;
   	server |node_2_ip|:8080;
   	server |node_3_ip|:8080;
   	server |node_4_ip|:8080;
  }

  server {
     listen 8081;
     location / {
       proxy_pass http://backend;
     }
  }

This configuration creates an ``nginx`` loadbalancer that passes requests on |control_public_ip| for ``/`` between your site-a and site-b nodes.

Next, create a :dockerfile:`Dockerfile<>` to build an ``nginx`` container image that includes the custom configuration.

Creating the nginx Dockerfile
``````````````````````````````

Create a file at ``~/ansible-for-devops-workshop/nginx-lb/Dockerfile`` with the following contents.

.. code-block:: bash

  $ cd ~/ansible-for-devops-workshop
  $ vim ~/ansible-for-devops-workshop/nginx-lb/Dockerfile

.. parsed-literal::

  FROM nginx
  USER root
  MAINTAINER |student_name|
  RUN rm /etc/nginx/conf.d/default.conf
  COPY ./etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

With all of the artifacts created, go ahead and commit them to your git repository.  Next you'll create the build pipeline and write the Ansible playbooks to deploy your nginx load balancer on your control node.

Creating the nginx container repo, build trigger and image
``````````````````````````````````````````````````````````

You'll need to log into Quay.io :quay:`quay.io<>` to create the repository that we are going to use today.  At the top right of the screen click the |plus sign| and select ``New Repository``.

In the ``Create New Repository`` page, we will need to make a few changes.  First let's give the repository a name. We are going to use ``ansible-for-devops-nginx-lb``.

Next we will select the ``Public`` radio button.  This will allow anyone to see and pull from the repository.  Also it is free :)

For the next selection we will ``Link to Github Repository Push`` and select ``Create Public Repository`` button.

Select the Organization that you created and select Continue, next we will select the ``ansibe-for-devops-workshop`` repository and hit continue.

For the Trigger, leave the ``default`` option and hit continue.

On the ``Select Dockerfile`` page, click the dropdown arrow and select ``/nginx-lb/Dockerfile`` and select continue.

For the context, you must select ``/nginx-lb``.  If not then the build will fail.  The context refers to where is path that it should start in when referencing things.

We will not be selecting a robot account, so hit continue and the "Ready to Go" will appear, from there we can select ``Continue`` and this will complete the Build Trigger.

Back on the build page, click the gear icon and next to your newly created ``Build Triggers``.   Select ``Run Trigger Now`` and for Branch/Tag select ``master``, then hit ``Start Build``.

In the ``Build History`` above you will now see a build that is running, click the ``Build ID`` and watch your container being built!!

Your custom nginx-lb image is now in your :quay:`quay.io<>` container registry. Your next playbook will deploy your nginx-lb to your control node.

Deploying your nginx load balancer
-----------------------------------

Now we can create a playbook that will deploy the load balancer.

Create a playbook named ``~/ansible-for-devops-workshop/nginx-lb-deploy.yml`` with the following content.

.. code-block:: bash

  $ cd ~/ansible-for-devops-workshop
  $ vim ~/ansible-for-devops-workshop/nginx-lb-deploy.yml


.. code-block:: yaml

  ---
  - name: deploy nginx load balancer
    hosts: lb
    become: yes

    tasks:
      - name: install docker preqequisities
        pip:
          name: docker

      - name: launch nginx-lb container on lb nodes
        docker_container:
         name: nginx-lb
         image: quay.io/|student_name|/ansible-for-devops-nginx-lb
         ports:
            - "8081:8081"
         restart_policy: always
         pull: yes

We are NOT going to run the playbook yet, this will be done in Ansible Tower.

Summary
--------

This lab is the completion of your website's and our load balancer config build. In the next lab you'll pull a MOTD banner from Ansible Galaxy and get it ready to be deployed by Ansible Tower.
