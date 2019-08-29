.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

========================
Deploying to Production
========================

Overview
`````````

Now it is time to deploy to production.

Create the requirements.yml
```````````````````````````````````````

First we must create a requirements.yml, this will tell Ansible Tower to import the needed roles from Ansible Galaxy.


.. code-block:: bash

  $ cd ~/devops-workshop/roles
  $ vim requirements.yml


.. code-block:: yaml

  ---
  - src: RedHatOfficial.rhel7_stig
  - src: nginxinc.nginx


Configure Ansible Tower
```````````````````````````````````````


Set Up Credentials
^^^^^^^^^^^^^^^^^^^

Gogs and student machine Credentials

Add a Project
^^^^^^^^^^^^^

Point Tower to the Gogs server


Create a Stig template
^^^^^^^^^^^^^^^^^^^^^^^


Create a Site A template
^^^^^^^^^^^^^^^^^^^^^^^^

Create a Site B template
^^^^^^^^^^^^^^^^^^^^^^^^

Create a NGINX template
^^^^^^^^^^^^^^^^^^^^^^^^


Create a Workflow
^^^^^^^^^^^^^^^^^


Create a STIG Check template
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
