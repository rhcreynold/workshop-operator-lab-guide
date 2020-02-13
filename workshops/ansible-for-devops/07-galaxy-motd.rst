.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

=======================
Ansible Galaxy and MOTD
=======================
Overview
`````````
In this exercise we are going get an MOTD banner from :ansible_galaxy:`galaxy.ansible.com<jtyr/motd>` and add it to your Github repository.


What is Ansible Galaxy?
```````````````````````
Jump-start your automation project with great content from the Ansible community. Galaxy provides pre-packaged units of work known to Ansible as roles.
Roles can be dropped into Ansible PlayBooks and immediately put to work. You'll find roles for provisioning infrastructure, deploying applications, and all of the tasks you do everyday.

Getting content from Ansible Galaxy
`````````
By default when you install a role from Ansible Galaxy it is stored in ``/etc/ansible/roles`` which is available to all user system wide.  In this case we
want to install the roles into our own ``~/ansible-for-devops-workshop/roles`` folder so we can easily add it to our Github repo.

We are going to use the motd from :ansible_galaxy:`galaxy.ansible.com<jtyr/motd>`, so let go ahead and get a hold of it.

.. code-block:: bash

  $ cd ~/ansible-for-devops-workshop
  $ ansible-galaxy install --roles-path ~/ansible-for-devops-workshop/roles/ jtyr.motd

Now we can create a playbook that will use our new role.

.. code-block:: bash

  $ vim motd.yml

.. code-block:: yaml

  ---
  - name: Deploy site web infrastructure
    hosts: all
    become: yes

    roles:
      - jtyr.motd


We are NOT going to run the playbook yet, we will save this for Ansible Tower.

Summary
--------

This lab has set the MOTD from Ansible Galaxy.  In the next lab we will get Ansible Tower configured and then start running playbooks!
