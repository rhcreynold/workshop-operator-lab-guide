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
