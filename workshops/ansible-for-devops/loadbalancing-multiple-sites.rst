.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==================
Deploying the nginx server
==================

Overview
`````````

For this exercise we are going to deploy an nginx reverse proxy and loadbalancer.  This will take incoming http requests over port 8080
and forward them to one of the 4 webservers that we have deployed.

Get the nginx role from Ansible Galaxy
```````````````````````````````````````

We will be pulling the role from https://galaxy.ansible.com/nginxinc/nginx
To install this role to be used locally we will need to run the ansible galaxy command from the README


.. code-block:: bash

  $ ansible-galaxy install nginxinc.nginx




OUTPUT GOES HERE


Once we have the role installed, it is time to create the playbook that will install the nginx server.


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
      vars:
        nginx_http_template_enable: true
        nginx_http_template:
          default:
            template_file: http/default.conf.j2
            conf_file_name: default.conf
            conf_file_location: /etc/nginx/conf.d/
            port: 8080
            server_name: |control_public_ip|
            error_page: /usr/share/nginx/html
            autoindex: false
            reverse_proxy:
              locations:
                backend:
                  location: /
                  proxy_pass: http://backend_servers
                  proxy_set_header:
                    header_host:
                      name: Host
                      value: $host
                    header_x_real_ip:
                      name: X-Real-IP
                      value: $remote_addr
                    header_x_forwarded_for:
                      name: X-Forwarded-For
                      value: $proxy_add_x_forwarded_for
                    header_x_forwarded_proto:
                      name: X-Forwarded-Proto
                      value: $scheme
            upstreams:
              upstream_1:
                name: backend_servers
                lb_method: least_conn
                zone_name: backend
                zone_size: 64k
                sticky_cookie: false
                servers:
                  backend_server_1:
                    address: |node_1_ip|
                    port: 8080
                    weight: 1
                    health_check: max_fails=3 fail_timeout=5s
                  backend_server_2:
                    address: |node_2_ip|
                    port: 8080
                    weight: 1
                    health_check: max_fails=3 fail_timeout=5s
                  backend_server_3:
                    address: |node_3_ip|
                    port: 8080
                    weight: 1
                    health_check: max_fails=3 fail_timeout=5s
                  backend_server_4:
                    address: |node_4_ip|
                    port: 8080
                    weight: 1
                    health_check: max_fails=3 fail_timeout=5s


So what we have done is create a loadbalancer that answers on |control_public_ip| and then will forward the request to one of the backend_servers.



Now that we have the playbook written it is time to execute it.

.. code-block:: bash

  $ ansible-playbook setup-nginx.yml


  OUTPUT GOES HERE
