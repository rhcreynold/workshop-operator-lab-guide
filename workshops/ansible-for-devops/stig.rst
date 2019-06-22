.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==================
STIG the Environment
==================

Overview
`````````

For this excersize we are going to STIG the Environment to make sure we are complying with our security officers demands.



Get the RHEL 7 STIG role from Ansible Galaxy
```````````````````````````````````````

We will be pulling the role from https://galaxy.ansible.com/RedHatOfficial/rhel7_stig
To install this role to be used locally we will need to run the ansible galaxy command from the README


.. code-block:: bash

  $ ansible-galaxy install redhatofficial.rhel7_stig




OUTPUT GOES HERE


Once we have the role installed, it is time to create the playbook that will install the stig all the servers.


Create the stig Playbook
````````````````````````````
Let create the file for the playbook to live in.


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
      service_firewalld_enabled: false #since using a cloud image, we need to skip this
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
The first tasks sets the sebooklean to allow http connections to our webservers and containers.  The second tasks allows us to make sure tcp connections
are forward from the host to the container that is serving our content.

Now let us run the playbook to STIG the Environment.


  .. code-block:: bash

      $ ansible-playbook stig.yml


OUTPUT GOES HERE
