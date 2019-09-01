.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

============================
Deploying your prod cluster
============================

Overview
`````````

Now that we have our operational infrastructure secured, in this lab you'll deploy your production web server infrastructure. To do this, you'll create an Ansible Role. Our web application will display the hostname of each server.

Adding prod hosts to your inventory
``````````````````````````````````````````

First, modify your ansible inventory at ``~/playbook/hosts`` to add a new groupe named ``prod`` with the IP addresses for your production hosts as members.

.. parsed-literal::
  [gogs]
  |control_public_ip|

  [registry]
  |control_public_ip|

  [prod]
  |node_1_ip|
  |node_2_ip|

Next we'll create the Ansible content to deploy our production application.

Creating a development site deployment role
``````````````````````````````````````````````

Next, move over to the ``~/devops-workshop/roles`` directory and create a new Ansible role using ``ansible-galaxy`` named ``apache-simple``.

.. code-block:: bash

  $ cd ~/playbook/roles
  $ ansible-galaxy init apache-simple

Role defaults
~~~~~~~~~~~~~~~~~~~~~~~~~~

Your role needs some default values for variables in ``~/playbook/roles/apache-simple/defaults/main.yml``. Edit your file to look like the example below.

Default values are used for variables by Ansible if they're not set in any other location. In Ansible, you can set variable values in 22 different locations, each of which have an assigned `level of precedence<https://docs.ansible.com/ansible/2.5/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable>`__.

.. code-block:: yaml

  ---
  # defaults file for apache-simple
  apache_test_message: This is a test message
  apache_max_keep_alive_requests: 115
  apache_webserver_port: 8080

Role variables
~~~~~~~~~~~~~~~

Next, add the following role-specific variables in ``~/playbook/roles/apache-simple/vars/main.yml.``

.. code-block:: yaml

  # vars file for apache-simple
  httpd_packages:
    - httpd
    - mod_wsgi

Role handlers
~~~~~~~~~~~~~~

Your ``apache-simple`` role needs a `handler task<https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#handlers-running-operations-on-change>`__ as well in ``~/playbook/roles/apache-simple/handlers/main.yml``. Handler tasks are special tasks in an Ansible role or playbook that can be triggered by another task or tasks when the original task has caused a change to the system.

.. admonition:: Designing for minimal disruption

  Ansible encourages you to design workflows that are as minimally disruptive as possible. 100% uptime (and even "5 9's" if we want to be real about it) is a myth.

  But you don't have to reboot servers and restart services as a matter of course. Ansible makes minimal disruption to your infrastructure and services a practical reality.

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

Your role needs two Ansible templates in ``~/playbook/roles/apache-simple/templates/``. To save time, we've made these available for your to download directly.

.. code-block:: yaml

  $ cd ~/playbook/roles/apache-simple/templates/
  $ curl -O https://raw.githubusercontent.com/ansible/lightbulb/master/examples/apache-role/roles/apache-simple/templates/httpd.conf.j2
  $ curl -O https://raw.githubusercontent.com/ansible/lightbulb/master/examples/apache-role/roles/apache-simple/templates/index.html.j2

Role tasks
~~~~~~~~~~~

Finally, create tasks for your role that reference your defaults, variables, handlers, and templates in ``~/playbook/roles/apache-simple/tasks/main.yml``.

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

Next, create a playbook to apply the new role to your production hosts.

Creating a production playbook
````````````````````````````

Create an Ansible playbook at ``~/playbook/prod.yml`` with the following content.

.. code-block:: yaml

  ---
  - name: Deploy site web infrastructure
    hosts: prod
    become: yes

    roles:
      - apache-simple

With your playbook created, it's time to deploy production.

Deploying production
``````````````````

To deploy your production application, use the ``ansible-playbook`` command to execute your new playbook.

.. code-block:: bash

  $ ansible-playbook -i hosts ~/devops-workshop/prod.yml

Summary
````````
