.. sectionauthor: Ajay Chenampara <achenamp@redhat.com>
.. _docs admin: jduncan@redhat.com

Configuring Ansible Tower
=========================

In this exercise, we are going to configure Tower so that we can run a
playbook.

Configuring Ansible Tower
-------------------------

There are a number of contructs in the Ansible Tower UI that enable
multi-tenancy, notifications, scheduling, etc. However, we are only
going to focus on a few of the key contructs that are required for this
workshop today.

-  Credentials
-  Projects
-  Inventory
-  Job Template

Logging into Tower and Installing the License Key
-------------------------------------------------

Step 1:
~~~~~~~

To log in, use the username ``admin`` and and the password
``ansibleWS``. Recall that this username/password was created when you built the inventory to setup Tower.

.. figure:: _static/images/tower_install_splash.png
   :alt: Ansible Tower Login Screen

   Ansible Tower Login Screen
As soon as you login, you will prompted to request a license or browse
for an existing license file

.. figure:: ./_static/images/at_lic_prompt.png
   :alt: Uploading a License

   Uploading a License
Step 2:
~~~~~~~

In a separate browser tab, browse to
https://www.ansible.com/workshop-license to request a workshop license.

Step 3:
~~~~~~~

Back in the Tower UI, choose BROWSE |Browse button| and upload your
recently downloaded license file into Tower.

Step 4:
~~~~~~~

Select "*I agree to the End User License Agreement*\ "

Step 5:
~~~~~~~

Click on SUBMIT |Submit button|

Creating a Credential
---------------------

Credentials are utilized by Tower for authentication when launching jobs
against machines, synchronizing with inventory sources, and importing
project content from a version control system.

There are many `types of
credentials <http://docs.ansible.com/ansible-tower/latest/html/userguide/credentials.html#credential-types>`__
including machine, network, and various cloud providers. In this
workshop, we are using a *machine* credential.

Step 1:
~~~~~~~

Select the gear icon |Gear button|

Step 2:
~~~~~~~

Select CREDENTIALS

Step 3:
~~~~~~~

Click on ADD |Add button|

Step 4:
~~~~~~~

Complete the credential form using the following entries:

+------------------------+---------------------------------------+
| NAME                   | Ansible Workshop Credential           |
+========================+=======================================+
| DESCRIPTION            | Credentials for Ansible Workshop      |
+------------------------+---------------------------------------+
| ORGANIZATION           | Default                               |
+------------------------+---------------------------------------+
| TYPE                   | Machine                               |
+------------------------+---------------------------------------+
| USERNAME               | Your Workshop Username - Student(x)   |
+------------------------+---------------------------------------+
| PASSWORD               | Your Workshop Password                |
+------------------------+---------------------------------------+
| PRIVILEGE ESCALATION   | Sudo (This is the default)            |
+------------------------+---------------------------------------+

.. figure:: ./_static/images/at_cred_detail.png
   :alt: Adding a Credential

   Adding a Credential
Step 5:
~~~~~~~

Select SAVE |Save button|

Creating a Project
------------------

A Project is a logical collection of Ansible playbooks, represented in
Tower. You can manage playbooks and playbook directories by either
placing them manually under the Project Base Path on your Tower server,
or by placing your playbooks into a source code management (SCM) system
supported by Tower, including Git, Subversion, and Mercurial.

Step 1:
~~~~~~~

Click on PROJECTS

Step 2:
~~~~~~~

Select ADD |Add button|

Step 3:
~~~~~~~

Complete the form using the following entries

================== ===================================================
NAME               Ansible Workshop Project
================== ===================================================
DESCRIPTION        workshop playbooks
ORGANIZATION       Default
SCM TYPE           Git
SCM URL            https://github.com/ansible/lightbulb
SCM BRANCH        
SCM UPDATE OPTIONS [x] Clean [x] Delete on Update [x] Update on Launch
================== ===================================================

.. figure:: ./_static/images/at_project_detail.png
   :alt: Defining a Project

   Defining a Project
Step 4:
~~~~~~~

Select SAVE |Save button|

Creating a Inventory
--------------------

An inventory is a collection of hosts against which jobs may be
launched. Inventories are divided into groups and these groups contain
the actual hosts. Groups may be sourced manually, by entering host names
into Tower, or from one of Ansible Tower’s supported cloud providers.

An Inventory can also be imported into Tower using the ``tower-manage``
command and this is how we are going to add an inventory for this
workshop.

Step 1:
~~~~~~~

Click on INVENTORIES

Step 2:
~~~~~~~

Select ADD |Add button|

Step 3:
~~~~~~~

Complete the form using the following entries

+----------------+------------------------------+
| NAME           | Ansible Workshop Inventory   |
+================+==============================+
| DESCRIPTION    | Ansible Inventory            |
+----------------+------------------------------+
| ORGANIZATION   | Default                      |
+----------------+------------------------------+

.. figure:: ./_static/images/at_inv_create.png
   :alt: Create an Inventory

   Create an Inventory
Step 4:
~~~~~~~

Select SAVE |Save button|

Step 5:
~~~~~~~

Look in your ``.ansible.cfg`` file to find the path to your inventory
file (``cat ~/.ansible.cfg``) .Use the ``tower-manage`` command to
import an existing inventory.

::

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
