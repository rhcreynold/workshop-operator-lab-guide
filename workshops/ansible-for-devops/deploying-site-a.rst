.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==================
Deploying Site A
==================

Overview
`````````

We have gone ahead and stood up two Red Hat Enterprise Linux hosts for you.  In this lab we are going to
deploy a simple web application (from an Ansible Role) on two different hosts. This will host a simple
website display the hostname.

Now let us create the Ansible role structure, but first we need to get into the right folder.

.. code-block:: bash

  $ cd ~/devops-workshop
  $ cd roles


Now let's create the Ansible Role structure

.. code-block:: bash

  $ ansible-galaxy init apache-simple

Let us create a site.yml to invoke the role.

.. code-block:: yaml

  ---
  - name: Ensure apache is installed and started via role
    hosts: web
    become: yes

    roles:
      - apache-simple


Now let us add some default variables to your role in ``roles/apache-simple/defaults/main.yml.``

.. code-block:: yaml

  ---
  # defaults file for apache-simple
  apache_test_message: This is a test message
  apache_max_keep_alive_requests: 115

Now lets create some role-specific variables to your role in ``roles/apache-simple/vars/main.yml.``

.. code-block:: yaml

  # vars file for apache-simple
  httpd_packages:
    - httpd
    - mod_wsgi


Create your role handler in ``roles/apache-simple/handlers/main.yml.``

.. code-block:: yaml

  ---
  # handlers file for apache-simple
  - name: restart-apache-service
  service:
    name: httpd
    state: restarted
    enabled: yes

Add tasks to your role in roles/apache-simple/tasks/main.yml.

.. code-block:: yaml

  ---
  # tasks file for apache-simple
  - name: Ensure httpd packages are installed
  yum:
    name: "{{ item }}"
    state: present
  with_items: "{{ httpd_packages }}"
  notify: restart-apache-service

  - name: Ensure site-enabled directory is created
  file:
    name: /etc/httpd/conf/sites-enabled
    state: directory

  - name: Copy httpd.conf
  template:
    src: templates/httpd.conf.j2
    dest: /etc/httpd/conf/httpd.conf
  notify: restart-apache-service

  - name: Copy index.html
  template:
    src: templates/index.html.j2
    dest: /var/www/html/index.html

  - name: Ensure httpd is started
  service:
    name: httpd
    state: started
    enabled: yes

Download a couple of templates into ``roles/apache-simple/templates/``

.. code-block:: yaml

  $ mkdir -p ~/apache-role/roles/apache-simple/templates/
  $ cd ~/apache-role/roles/apache-simple/templates/
  $ curl -O https://raw.githubusercontent.com/ansible/lightbulb/master/examples/apache-role/roles/apache-simple/templates/httpd.conf.j2
  $ curl -O https://raw.githubusercontent.com/ansible/lightbulb/master/examples/apache-role/roles/apache-simple/templates/index.html.j2

Now let us run the playbook.

.. code-block:: bash

  $ ansible-playbook site.yml
