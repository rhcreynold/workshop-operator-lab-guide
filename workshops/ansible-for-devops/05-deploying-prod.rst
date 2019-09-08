.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

============================
Deploying to prod
============================

Overview
`````````

With your operational infrastructure secured, in this lab you'll deploy your production web application. To do this, you'll create an :ansible_docs:`Ansible Role<user_guide/playbooks_reuse_roles.html>`. Your web application will display the hostname of the responding server for the content. The first thing to do is to create a group for your production nodes.

Adding prod hosts to your inventory
``````````````````````````````````````````

Modify your ansible inventory at ``~/playbook/hosts`` to add a new group named ``prod`` with the IP addresses for your production hosts as members.

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

Next, create the Ansible role to deploy your production application.

Creating a production site deployment role
``````````````````````````````````````````````

Next, move over to the ``~/playbook/roles`` directory and create a new Ansible role using ``ansible-galaxy`` named ``apache-simple``.

.. code-block:: bash

  $ cd ~/playbook/roles
  $ ansible-galaxy init apache-simple

Your newly created role is essentially empty, like the roles you created when :ref:`GOGS` and :ref:`Container Registry`. Next, you'll add the code to deploy your production environment.

Defaults
~~~~~~~~~~~~~~~~~~~~~~~~~~

Your role needs some default values for variables in ``~/playbook/roles/apache-simple/defaults/main.yml``. Edit your file to look like the example below.

Default values are used for variables by Ansible if they're not set in any other location. In Ansible, you can set variable values in 22 different locations, each of which have an assigned :ansible_docs:`level of precedence<user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable>`.

.. code-block:: yaml

  ---
  # defaults file for apache-simple
  apache_test_message: This is a test message
  apache_max_keep_alive_requests: 115
  apache_webserver_port: 8080

With your defaults created, next you'll create variables for your role.

Variables
~~~~~~~~~~~~~~~

Next, add the following role-specific variables in ``~/playbook/roles/apache-simple/vars/main.yml.``

.. code-block:: yaml

  # vars file for apache-simple
  httpd_packages:
    - httpd
    - mod_wsgi

With your variables created, next you'll add a handler task to your ``apache-simple`` role.

Handlers
~~~~~~~~~~~~~~

Your ``apache-simple`` role needs a :ansible_docs:`handler task<user_guide/playbooks_intro.html#handlers-running-operations-on-change>` as well in ``~/playbook/roles/apache-simple/handlers/main.yml``. Handler tasks are special tasks in an Ansible role or playbook that can be triggered by another task or tasks when the original task has caused a change to the system.

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

Templates
~~~~~~~~~~~~~~~

The :ansible_docs:`template<modules/template_module.html>` module uses the :jinja2:`Jinja2<>` templating language to create dynamic documents with variables during a playbook run.

Your role needs two Ansible templates in ``~/playbook/roles/apache-simple/templates/``. To save time, we've made these available for your to download directly.

.. code-block:: yaml

  $ cd ~/playbook/roles/apache-simple/templates/
  $ curl -O https://raw.githubusercontent.com/ansible/lightbulb/master/examples/apache-role/roles/apache-simple/templates/httpd.conf.j2
  $ curl -O https://raw.githubusercontent.com/ansible/lightbulb/master/examples/apache-role/roles/apache-simple/templates/index.html.j2

The final component for your ``apache-simple`` role is to create the actual tasks that it will excecute to deploy your production application.

Tasks
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

With your playbook created, it's time to commit your source code and deploy your production application.

Committing your source code
``````````````````````````````

Be sure to add your new files to source control and push your source to your its repository.

.. code-block:: bash

  $ cd ~/playbook
  $ git add -A
  $ git commit -a -m 'adding production deployment code'
  $ git push origin master

The ``git push`` command will prompt you for your GOGS password just like your previous push. Your output should look similar to the example below:

.. code-block:: bash

  ...
  Username for 'http://54.89.149.44:8081': student1
  Password for 'http://student1@54.89.149.44:8081':
  To http://54.89.149.44:8081/student1/playbook.git
   70fd216..c27fd85  master -> master

Deploying production
`````````````````````

To deploy your production application, use the ``ansible-playbook`` command to execute your new playbook.

.. code-block:: bash

  $ cd ~/playbook
  $ ansible-playbook -i hosts prod.yml -k

Confirming a successful deployment
```````````````````````````````````

To confirm your playbook performed properly, use the ``curl`` command to access each production server on port 8080.

.. parsed-literal::

  $ curl \http://|node_1_ip|:8080
  $ curl \http://|node_2_ip|:8080

Summary
````````

This lab used Ansible to deploy your production application in a 'traditional' fashion. You deployed and configured a RHEL 7 Linux system by installing RPMs, configuring files, and enabling services.

In the next lab you'll deploy your next-generation development environment. You'll be deploying the same application. Only it will be completely containerized.
