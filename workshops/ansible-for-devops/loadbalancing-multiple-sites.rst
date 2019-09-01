.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

=================================
Load balancing your sites
=================================

Overview
`````````

In exercise we're going to deploy an nginx reverse proxy and loadbalancer.  This proxy will take incoming http requests over port 8080
and forward them to one of the 4 webservers that we have deployed. To be consistent, we'll be containerizing nginx.

Creating the nginx container image
```````````````````````````````````````

Setting up nginx.conf
~~~~~~~~~~~~~~~~~~~~~~~

To configure nginx to act as a load balancer you need to edit the configuration file ``/etc/nginx/conf.d/default.conf`` inside the container image. The first step is to create the proper configuration file.

Create a directory named ``~/devops-workshop/nginx-loadbalancer`` on your control node. Inside that directoy create a file named ``default.conf`` with the following contents:

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
      location /dev {
        proxy_pass \http://dev;
      }
      location /prod {
        proxy_pass \http://prod;
      }
  }

This creates an ``nginx`` loadbalancer that passes requests on |control_public_ip| for ``/dev`` between your dev servers and requests for ``/prod`` to your production systems.

Next we'll create a Dockerfile to create an ``nginx`` container image that includes the custom configuration.

Creating the nginx Dockerfile
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To get our custom configuration file into the base nginx image we'll need to create a new container image with the configuration file. To do this we'll need a ``Dockerfile``

.. parsed-literal::

  FROM nginx
  USER root
  MAINTAINER |student_name|
  RUN rm /etc/nginx/conf.d/default.conf
  COPY nginx.conf /etc/nginx/conf.d/default.conf


Create the nginx Playbook
````````````````````````````
Let create the file for the playbook to live in.


  .. code-block:: bash

    $ cd ~/devops-workshop
    $ vim setup-nginx.yml



Role tasks
~~~~~~~~~~~
.. parsed-literal::

    ---
    - hosts: localhost
      become: true
      roles:
        - role: nginxinc.nginx



So what we have done is create a loadbalancer that answers on |control_public_ip| and then will forward the request to one of the backend_servers.



Now that we have the playbook written it is time to execute it.

.. code-block:: bash

  $ ansible-playbook setup-nginx.yml


  OUTPUT GOES HERE
