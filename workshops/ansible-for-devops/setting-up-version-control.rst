.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>
.. _docs admin: jduncan@redhat.com

===========================
Setting up Version Control
===========================

Overview
`````````

In this lab you'll configure your bastion host to serve your playbooks and other content for the rest of today's lab. We'll be using `GOGS <https://gogs.io/>`__ deployed in a container for this. Our tasks for this lab are to:

1. Write a playbook to deploy GOGS on your bastion host
2. Deploy GOGS and confirm it's functioning properly

.. admonition:: Do I need to configure docker?!

  Your bastion host already has all the dependencies to run docker containers. That's because this lab guide is already running on your bastion host inside a container!

Let's get started.

Creating an initial inventory
``````````````````````````````

Creating a GOGS role
`````````````````````

As we stated in the initial presentation, we're going to do our best to follow Ansible best practices in all of these labs. One of the key best practices is to use roles in (practically) every situtation. Deploying GOGS will be no different. To create a role, we use the ``ansible-galaxy`` command.

.. code-block:: bash
  $ ansible-galaxy init gogs



Writing your GOGS playbook
```````````````````````````

.. code-block:: yaml

  ...
  - name: deploy GOGS to bastion host
    hosts: control
    - tasks:

      name: pull GOGS image
