.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

=================================
Load-balancing your clusters
=================================

Overview
`````````

In exercise we're going to deploy an :nginx:`nginx<>` reverse proxy and load balancer.  This proxy will take incoming http requests over port 8081
and forward them to one of the 4 webservers that we have deployed. Like most of your other services in today's workshop, you'll be containerizing nginx.

Adding a load balancer inventory group
---------------------------------------

Like your other services, your load balancer needs a group in your Ansible inventory at ``~/playbook/hosts``. Add a group named ``lb`` with the IP address of your control node.

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

  [lb]
  |control_public_ip|

With your inventory group created, it's time to move on to customizing your nginx configuration and building a custom container image.

Creating the nginx container image
-----------------------------------

Nginx has a built-in module that acts as a reverse proxy load balancer named ``proxy_pass``. You'll need to configure that module as well as an ``upstream`` server group for both dev and prod in your ``nginx.conf`` configuration file at ``/etc/nginx/conf.d/default.conf``.

Setting up nginx.conf
~~~~~~~~~~~~~~~~~~~~~~~

The first step to create your customized nginx container is to create the proper configuration file.

Create a directory named ``~/playbook/nginx-lb`` on your control node. Inside that directoy create a file named ``default.conf`` with the following contents:

.. parsed-literal::

  upstream prod {
    server |node_1_ip|;
    server |node_2_ip|;
  }

  upstream dev {
    server |node_3_ip|;
    server |node_4_ip|;
  }

  server {
      listen 8081;
      location /dev {
        proxy_pass \http://dev;
      }
      location /prod {
        proxy_pass \http://prod;
      }
  }

This configuration creates an ``nginx`` loadbalancer that passes requests on |control_public_ip| for ``/dev`` between your dev nodes and requests for ``/prod`` to your production nodes.

Next, create a :dockerfile:`Dockerfile<>` to build an ``nginx`` container image that includes the custom configuration.

Creating the nginx Dockerfile
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a file at ``~/plabybook/nginx-lb/Dockerfile with the following contents. *Note: The capitalization of ``Dockerfile`` is important*

.. parsed-literal::

  FROM nginx
  USER root
  MAINTAINER |student_name|
  RUN rm /etc/nginx/conf.d/default.conf
  COPY nginx.conf /etc/nginx/conf.d/default.conf

With all of the artifacts created, next you'll write Ansible playbooks to build the container image and deploy your nginx load balancer on your control node.

Create the nginx container image
``````````````````````````````````
Similar to your development website, you'll create a playbook to build and push your container image and a second playbook to deploy it.

  .. code-block:: bash

    $ cd ~/playbook
    $ vim nginx-lb-build.yml

The load balancer build playbook should have the following content:

.. parsed-literal::

  ---
  - name: Ensure apache is installed and started via role
    hosts: localhost
    become: yes
    roles:
      - apache-simple

    tasks:

     - name: build a new docker image
       command: "docker build -t nginx-lb ."

     - name: Tag and push to registry
       docker_image:
         name: apache-simple
         repository: |control_public_ip|:5000/|student_name|/nginx-lb
         push: yes
         source: local
         tag: latest

To build your container image and push it to your registery, run the playbook using the ``ansible-playbook`` command:

.. code-block:: bash

  $ cd ~/playbook
  $ ansible-playbook -i hosts nginx-lb-build.yml

With the successful completion of this playbook run, your container image is now available in your container registry. Let's deploy it on the proper nodes with another playbook.

Deploying your nginx load balancer
```````````````````````````````````

Create a playbook named ``~/playbook/nginx-lb-deploy.yml`` with the following content.





So what we have done is create a loadbalancer that answers on |control_public_ip| and then will forward the request to one of the backend_servers.



Now that we have the playbook written it is time to execute it.

.. code-block:: bash

  $ ansible-playbook setup-nginx.yml


  OUTPUT GOES HERE
