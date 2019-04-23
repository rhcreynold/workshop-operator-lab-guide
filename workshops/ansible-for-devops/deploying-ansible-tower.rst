.. sectionauthor:: Ajay Chenampara <achenamp@redhat.com>
.. _docs admin: jduncan@redhat.com

=========================
Installing Ansible Tower
=========================

Exercise 1 - Installing Ansible Tower
------------------------------------
In this exercise, we are going to get Ansible Tower installed on your
control node

Installing Ansible Tower
------------------------

Step 1:
~~~~~~~

Change directories to /tmp

.. code:: bash

   cd /tmp

Step 2:
~~~~~~~

Download the latest Ansible Tower package

.. code:: bash

   curl -O https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz

Step 3:
~~~~~~~

Untar and unzip the package file

.. code:: bash

   tar xvfz /tmp/ansible-tower-setup-latest.tar.gz

Step 4:
~~~~~~~

Change directories into the ansible tower package

.. code:: bash

   cd /tmp/ansible-tower-setup-*/


