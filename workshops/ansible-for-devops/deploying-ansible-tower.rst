.. sectionauthor:: Ajay Chenampara <achenamp@redhat.com>
.. _docs admin: jduncan@redhat.com

==================================================
Installing and Configuring Ansible Tower
==================================================

Overview
---------
In this lab will you'll be working with Ansible Tower to make it how we interface with our playbooks, roles, and infrastructure for the rest of the workshop. You'll accomplish the following goals:

* Deploy Ansible Tower on your control node
* Configure Tower with your inventory, credentials, and to interface with GOGS to manage playbooks and roles.

The first step is to install Tower on your control node (|control_public_ip|).


Tower Installation
------------------------

The Ansible Tower installation process uses an ansible inventory and a script that calls Ansible playbooks to deploy Tower on your host. First, you need to download the Ansible Tower archive file, then configure your Tower inventory.

Downloading Ansible Tower
^^^^^^^^^^^^^^^^^^^^^^^^^^

Download the latest Tower release into ``/tmp`` on your control node.

.. code-block:: bash

  $ cd /tmp
  $ curl -O https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
  %   Total  %   Received % Xferd  Average Speed   Time     Time      Time     Current
                                   Dload  Upload   Total    Spent     Left     Speed
  100 5021k  100 5021k    0  0     27.5M      0   --:--:--  --:--:--  --:--:-- 27.5M

After this completes, extract the compressed file and ``cd`` into the uncompressed directory.

.. code-block:: bash

  $ tar xvfz /tmp/ansible-tower-setup-latest.tar.gz
  $ cd /tmp/ansible-tower-setup-*/

Next, you'll configure your Tower inventory.

Configuring your Tower inventory and beginning installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

 open the inventory file using ``vim`` (or another editor if you're more comfortable) and set the  ``admin_password``, ``pg_password``, and ``rabbitmq_password`` variables to |student_pass|.

 .. parsed-literal::

  [tower]
  localhost ansible_connection=local

  [database]

  [all:vars]
  admin_password='|student_pass|'

  pg_host=''
  pg_port=''

  pg_database='awx'
  pg_username='awx'
  pg_password='|student_pass|'

  rabbitmq_port=5672
  rabbitmq_vhost=tower
  rabbitmq_username=tower
  rabbitmq_password='|student_pass|'
  rabbitmq_cookie=cookiemonster

  = Needs to be true for fqdns and ip addresses
  rabbitmq_use_long_name=false

.. admonition:: What about more complex Tower deployments?

  By defining multiple hosts and some prescriptive group names in this same inventory, you can create HA Tower clusters across multiple datacenters and with multiple roles. This process is out of scope for this workshop, but you can find more information in the `Tower documentation <https://docs.ansible.com/ansible-tower/3.4.3/html/administration/clustering.html#ag-clustering>`__.

With your inventory configured, it's time to launch the installation process. Normally, this process will take approximately 25 minutes to run to completion. Luckily, this is where we've planned to start lunch.

.. code-block:: bash

  sudo ./setup.sh

Confirming success
^^^^^^^^^^^^^^^^^^^^

At this point, your Ansible Tower installation should be complete. You
can access your Tower through a browser pointed at |control_public_ip|.

This should land you at the installation splash screen.

.. figure:: _static/images/tower_install_splash.png
  :alt: Ansible Tower Login Screen

Next, we'll configure Tower with our credentials, projects, and inventories.

Configuring Ansible Tower
=========================

In this exercise, we are going to configure Tower to manage our infrastructure more effectively.

Overview
----------

There are a number of constructs in the Ansible Tower UI that enable multi-tenancy, notifications, scheduling, etc. Today we're going to focus on a few of the key constructs that are essential to any workflow.

-  Credentials
-  Projects
-  Inventory
-  Job Template

Before we configure these, though, we need to configure Tower with a License Key to enable the software.

Installing a License Key
-------------------------

To log in, use the username ``admin`` and and the password
|student_pass|. Recall that this username/password was created when you built the inventory to setup Tower.

.. figure:: _static/images/tower_install_splash.png
   :alt: Ansible Tower Login Screen

   Ansible Tower Login Screen

As soon as you login, you will prompted to request a license or browse
for an existing license file

.. figure:: ./_static/images/at_lic_prompt.png
   :alt: Uploading a License

   Uploading a License

In a separate browser tab, browse to
https://www.ansible.com/workshop-license to request a workshop license.

Back in the Tower UI, choose BROWSE |Browse button| and upload your
recently downloaded license file into Tower.

Select "*I agree to the End User License Agreement*\ "

Click on SUBMIT |Submit button|

Creating a Credential
---------------------

Credentials are utilized by Tower for authentication when launching jobs against machines, synchronizing with inventory sources, and importing project content from a version control system.

There are many `types of credentials <http://docs.ansible.com/ansible-tower/latest/html/userguide/credentials.html#credential-types>`__ including machine, network, and various cloud providers. In this workshop, we'll create a *machine* credential.

- Select the gear icon |Gear button|, then select CREDENTIALS.
- Click on ADD |Add button|


Use this information to complete the credential form.

+------------------------+---------------------------------------+
| NAME                   | Ansible Workshop Credential           |
+========================+=======================================+
| DESCRIPTION            | Credentials for Ansible Workshop      |
+------------------------+---------------------------------------+
| ORGANIZATION           | Default                               |
+------------------------+---------------------------------------+
| TYPE                   | Machine                               |
+------------------------+---------------------------------------+
| USERNAME               | |student_name|                        |
+------------------------+---------------------------------------+
| PASSWORD               | |student_pass|                        |
+------------------------+---------------------------------------+
| PRIVILEGE ESCALATION   | Sudo (This is the default)            |
+------------------------+---------------------------------------+

.. figure:: ./_static/images/at_cred_detail.png
   :alt: Adding a Credential

   Adding a Credential

- Select SAVE |Save button|

With your credential created, next you'll create a project to point back to your GOGS instance.

Creating a Project
-------------------

A Project is a logical collection of Ansible playbooks, represented in Tower. You can manage playbooks and playbook directories by either placing them manually under the Project Base Path on your Tower server, or by placing your playbooks into a source code management (SCM) system supported by Tower, including Git, Subversion, and Mercurial.

- Click on PROJECTS
- Select ADD |Add button|

Complete the form using the following entries

================== ===================================================
NAME               Ansible Workshop Project
================== ===================================================
DESCRIPTION        workshop playbooks
ORGANIZATION       Default
SCM TYPE           Git
SCM URL            \https://|control_public_ip|
SCM BRANCH
SCM UPDATE OPTIONS [x] Clean [x] Delete on Update [x] Update on Launch
================== ===================================================

.. figure:: ./_static/images/at_project_detail.png
   :alt: Defining a Project

   Defining a Project

- Select SAVE |Save button|

Creating an Inventory
-----------------------

An inventory is a collection of hosts against which jobs may be launched. Inventories are divided into groups and these groups contain the actual hosts. Groups may be sourced manually, by entering host names into Tower, or from one of Ansible Tower’s supported cloud providers.

An Inventory can also be imported into Tower using the ``tower-manage`` command and this is how we are going to add an inventory for this workshop.

- Click on INVENTORIES
- Select ADD |Add button|
- Complete the form using the following entries

+----------------+------------------------------+
| NAME           | Ansible Workshop Inventory   |
+================+==============================+
| DESCRIPTION    | Ansible Inventory            |
+----------------+------------------------------+
| ORGANIZATION   | Default                      |
+----------------+------------------------------+

.. figure:: ./_static/images/at_inv_create.png
   :alt: Create an Inventory

   Creating an Inventory

- Select SAVE |Save button|

### TODO - You're here right now, jduncan

Step 5:
~~~~~~~

Look in your ``.ansible.cfg`` file to find the path to your inventory
file (``cat ~/.ansible.cfg``) .Use the ``tower-manage`` command to
import an existing inventory.

.. code-block:: bash

    sudo tower-manage inventory_import --source=<location of you inventory> --inventory-name="Ansible Workshop Inventory"

You should see output similar to the following:

.. figure:: ./_static/images/at_tm_stdout.png
   :alt: Importing an inventory with tower-manage

   Importing an inventory with tower-manage

Feel free to browse your inventory in Tower. You should now notice that
the inventory has been populated with Groups and that each of those
groups contain hosts.

.. figure:: ./_static/images/at_inv_group.png
   :alt: Inventory with Groups

   Inventory with Groups

.. |Browse button| image:: ./_static/images/at_browse.png
.. |Submit button| image:: ./_static/images/at_submit.png
.. |Gear button| image:: ./_static/images/at_gear.png
.. |Add button| image:: ./_static/images/at_add.png
.. |Save button| image:: ./_static/images/at_save.png
