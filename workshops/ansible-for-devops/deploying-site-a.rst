.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==================
Deploying Site A
==================

Overview
`````````

Now that we have our operational infrastructure deployed, in this lab we'll deploy a our first site's web server infrastructure. To do this, we'll create an Ansible Role. Our web application will display the hostname of each server.

.. important::
  To save time, two RHEL 7 hosts that have been pre-provisioned for your Site A web hosts.

Adding hosts to your Ansible inventory
```````````````````````````````````````

First, modify your ansible inventory at ``~/devops-workshop/hosts`` to add a new groupe named ``siteA`` with the IP addresses for your hosts as members.

.. parsed-literal::
  [gogs]
  |control_public_ip|

  [dev]
  |node_1_ip|
  |node_2_ip|

Creating a development site deployment role
``````````````````````````````````````````````


Next, change to the ``~/devops-workshop/roles`` directory and create a new Ansible role using ``ansible-galaxy``.

.. code-block:: bash

  $ cd ~/devops-workshop
  $ cd roles
  $ ansible-galaxy init apache-simple

Role defaults
~~~~~~~~~~~~~~~~~~~~~~~~~~

Your role needs some default values for variables in ``roles/apache-simple/defaults/main.yml``. Edit your file to look like the example below.

.. code-block:: yaml

  ---
  # defaults file for apache-simple
  apache_test_message: This is a test message
  apache_max_keep_alive_requests: 115
  apache_webserver_port: 8080

Role variables
~~~~~~~~~~~~~~~

Next, add the following role-specific variables in ``roles/apache-simple/vars/main.yml.``

.. code-block:: yaml

  # vars file for apache-simple
  httpd_packages:
    - httpd
    - mod_wsgi

Role handlers
~~~~~~~~~~~~~~

Create your role handler in ``roles/apache-simple/handlers/main.yml.``

.. code-block:: yaml

  ---
  # handlers file for apache-simple
  - name: restart httpd service
  service:
    name: httpd
    state: restarted
    enabled: yes

Role templates
~~~~~~~~~~~~~~~

Your roles needs two Ansible templates in ``roles/apache-simple/templates/``. To save time, we've made these available for your to download directly using the following commands.

.. code-block:: yaml

  $ mkdir -p ~/apache-role/roles/apache-simple/templates/
  $ cd ~/apache-role/roles/apache-simple/templates/
  $ curl -O https://raw.githubusercontent.com/ansible/lightbulb/master/examples/apache-role/roles/apache-simple/templates/httpd.conf.j2
  $ curl -O https://raw.githubusercontent.com/ansible/lightbulb/master/examples/apache-role/roles/apache-simple/templates/index.html.j2

Role tasks
~~~~~~~~~~~

Finally, create tasks for your role that reference your defaults, variables, handlers, and templates in ``roles/apache-simple/tasks/main.yml``.

.. code-block:: yaml

  ---
  # tasks file for apache-simple
  - name: Ensure httpd packages are installed
  yum:
    name: "{{ item }}"
    state: present
  with_items: "{{ httpd_packages }}"
  notify: restart httpd service

  - name: Ensure site-enabled directory is created
  file:
    name: /etc/httpd/conf/sites-enabled
    state: directory

  - name: Copy httpd.conf
  template:
    src: templates/httpd.conf.j2
    dest: /etc/httpd/conf/httpd.conf
  notify: restart httpd service

  - name: Copy index.html
  template:
    src: templates/index.html.j2
    dest: /var/www/html/index.html

  - name: Ensure httpd is started
  service:
    name: httpd
    state: started
    enabled: yes

Next, we need to create a playbook to apply our new role to our Site A hosts.

Creating a Site A playbook
````````````````````````````

Create an Ansible playbook at ``~/devops-workshop/site.yml`` with the following content.

.. code-block:: yaml

  ---
  - name: Deploy site web infrastructure
    hosts: siteA
    become: yes

    roles:
      - apache-simple

With your playbook created, it's time to deploy Site A.

Deploying Site A
``````````````````

To deploy Site A, use the ``ansible-playbook`` command to execute your new playbook.

.. code-block:: bash

  $ ansible-playbook ~/devops-workshop/site.yml

Your output should look like this sample output:

.. code-block:: bash

  $ output goes here for reference

Summary
````````
