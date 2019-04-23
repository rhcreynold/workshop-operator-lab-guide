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

 
