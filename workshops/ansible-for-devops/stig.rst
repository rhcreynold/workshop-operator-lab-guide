.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==================
STIG the Environment
==================

Overview
`````````

For this excercise we are going to STIG the Environment to make sure we are complying with our security officers demands.

Get the RHEL 7 STIG role from Ansible Galaxy
```````````````````````````````````````

We'll pull the role from https://galaxy.ansible.com/RedHatOfficial/rhel7_stig
To install this role to be used locally we'll use the ``ansible-galaxy`` command.

.. code-block:: bash

  $ ansible-galaxy install redhatofficial.rhel7_stig
  - downloading role 'rhel7_stig', owned by redhatofficial
  - downloading role from https://github.com/RedHatOfficial/ansible-role-rhel7-stig/archive/0.1.44.tar.gz
  - extracting redhatofficial.rhel7_stig to /Users/jduncan/.ansible/roles/redhatofficial.rhel7_stig
  - redhatofficial.rhel7_stig (0.1.44) was installed successfully

With the role installed it's time to create the playbook to apply the STIG baseline to our hosts.

Writing the STIG Playbook
````````````````````````````
Create a file named ``~/devops/workshop/stig.yml``.

  .. code-block:: bash

    $ cd ~/devops-workshop
    $ vim stig.yml



Role tasks
~~~~~~~~~~~
.. parsed-literal::

  ---
  - hosts: all
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

As you can see we are adding two addition tasks and setting a variable.  Since we are using the cloud image for RHEL, there is no firewalld.
The first tasks sets the seboolean to allow http connections to our webservers and containers.  The second tasks allows us to make sure tcp connections
are forward from the host to the container that is serving our content.

Now let us run the playbook to STIG the Environment.


  .. code-block:: bash

      $ ansible-playbook stig.yml


OUTPUT GOES HERE
