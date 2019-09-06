.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==========================
Securing your environment
==========================

Overview
`````````

Before we deploy services and software, we need to ensure our infrastructure is secure. To accomplish this, we're going to apply the :stig:`RHEL 7 DISA STIG <>`.

it's time to edit your inventory to create a group that contains all four of your nodes.

Creating an Ansible inventory
`````````````````````````````````````````````

Ansible best practices include using inventory groups consistently. This makes your playbooks more portable. When your environment changes, only the inventory needs to be updated. Your roles and playbooks don't need to be edited.

To accomplish this we'll create inventory groups to easily accommodate your different workflows. Hosts can belong to multiple groups in the same inventory. Create a new inventory file named ``hosts`` at ``~/playbook/hosts``. You'll use this inventory for the rest of today's lab exercises. The first group to add to ``~/playbook/hosts`` is named ``nodes`` and contains all four of your web nodes. We'll use this group when we want to perform tasks on all the web servers at once.

.. parsed-literal::

  [nodes]
  |node_1_ip|
  |node_2_ip|
  |node_3_ip|
  |node_4_ip|

With your inventory created, you can create the playbook to apply the STIG baseline to your hosts.

Installing the RHEL 7 STIG role
`````````````````````````````````````````````````

The RHEL 7 DISA STIG is a set of guidelines to secure government servers. To implement it we'll use an Ansible role that's maintained by Red Hat. We'll pull the role from :ansible_galaxy:`Ansible Galaxy<RedHatOfficial/rhel7_stig>`
To install this role to be used locally we'll use the ``ansible-galaxy`` command on your control node.

.. code-block:: bash

  $ mkdir ~/playbook
  $ cd ~/playbook
  $ mkdir roles
  $ cd roles
  $ ansible-galaxy install redhatofficial.rhel7_stig
  - downloading role 'rhel7_stig', owned by redhatofficial
  - downloading role from https://github.com/RedHatOfficial/ansible-role-rhel7-stig/archive/0.1.44.tar.gz
  - extracting redhatofficial.rhel7_stig to /Users/jduncan/.ansible/roles/redhatofficial.rhel7_stig
  - redhatofficial.rhel7_stig (0.1.44) was installed successfully

With the RHEL 7 STIG role installed create a playbook to apply the role to your ``nodes`` group.

Writing your STIG Playbook
````````````````````````````
Create a file named ``~/playbook/stig.yml``. This file will be the playbook to secure your web servers.

  .. code-block:: bash

    $ cd ~/playbook
    $ vim stig.yml

Now let us run the playbook to STIG the Environment.

Role tasks
~~~~~~~~~~~
.. parsed-literal::

  ---
  - hosts: nodes
    become: true
    vars:
      service_firewalld_enabled: false
    roles:
       - { role: RedHatOfficial.rhel7_stig }

    tasks:
    - name: Set httpd_can_network_connect flag on and keep it persistent across reboots
      seboolean:
        name: httpd_can_network_connect
        state: yes
        persistent: yes

    - name: Ensure sysctl net.ipv4.ip_forward is set to 1
      sysctl:
        name: net.ipv4.ip_forward
        value: 1
        state: present
        reload: true

You're adding two additional tasks that run after the role is applied and also setting a variable used by the STIG role. Since we're using the cloud image for RHEL, ``firewalld`` isn't installed by default.

The first tasks sets an SELinux boolean that allows http connections to the  webservers and containers that will be running on the hosts. The second task allows ensures tcp connections are forward from the node to the containers that serve content. Next you need to run the playbook to apply the STIG baseline.

Running your STIG playbook
````````````````````````````

With your code finished, run the playbook using the ``ansible-playbook`` command.

  .. code-block:: bash

      $ cd ~/playbook
      $ ansible-playbook -i hosts stig.yml -k

This playbook will take a few minutes to complete. It's making a lot of changes to your system. It checks almost 500 things on the system in its default configuration.

.. code-block:: bash

PLAY RECAP *****************************************************************
172.16.121.0 : ok=467  changed=5    unreachable=0    failed=0    skipped=81   rescued=0    ignored=0
172.16.225.249 : ok=467  changed=5    unreachable=0    failed=0    skipped=81   rescued=0    ignored=0
172.16.228.125 : ok=467  changed=5    unreachable=0    failed=0    skipped=81   rescued=0    ignored=0
172.16.246.6 : ok=467  changed=5    unreachable=0    failed=0    skipped=81   rescued=0    ignored=0

Summary
````````
