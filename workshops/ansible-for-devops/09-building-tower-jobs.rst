.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==================================================
Building and Running a Ansible Tower Job
==================================================

In this lab will you'll be building a job template and running it via an Ansible Tower job.

Setting the MOTD
----------------

On the left hand side, select Templates.  Then select the ADD |Add button| on the top right side and select job template.

Use this information to complete the Job Template form.

+------------------------+---------------------------------------+
| NAME                   | MOTD Banner                           |
+========================+=======================================+
| DESCRIPTION            | Set the MOTD Banner for all hosts     |
+------------------------+---------------------------------------+
| JOB TYPE               | Run                                   |
+------------------------+---------------------------------------+
| INVENTORY              | Ansible Workshop Inventory            |
+------------------------+---------------------------------------+
| PROJECT                | Github                                |
+------------------------+---------------------------------------+
| PLAYBOOK               | motd.yml                              |
+------------------------+---------------------------------------+
| CREDENTIALS            | Ansible Workshop Credential           |
+------------------------+---------------------------------------+
| OPTIONS                | Enable Privilege Escalation           |
+------------------------+---------------------------------------+

Select the Launch button or the Rocket Icon at the bottom of the page, then watch the Ansible output.

You can verify that the MOTD has changed by logging out of your ssh session and logging back in, you will see something similar below:

.. parsed-literal::
        _              _ _     _
       / \   _ __  ___(_) |__ | | ___
      / _ \ | '_ \/ __| | '_ \| |/ _ \
     / ___ \| | | \__ \ | |_) | |  __/
    /_/   \_\_| |_|___/_|_.__/|_|\___|
      FQDN:    ansible
      Distro:  RedHat 7.7 Maipo
      Virtual: YES

      CPUs:    2
      RAM:     3.8GB



Configuring A Job Template For Site-A
-------------------------------------

On the left hand side, select Templates.  Then select the ADD |Add button| on the top right side and select job template.

Use this information to complete the Job Template form.

+------------------------+---------------------------------------+
| NAME                   | Ansible Workshop Website SiteA        |
+========================+=======================================+
| DESCRIPTION            | Deploy the Ansible Workshop Website   |
+------------------------+---------------------------------------+
| JOB TYPE               | Run                                   |
+------------------------+---------------------------------------+
| INVENTORY              | Ansible Workshop Inventory            |
+------------------------+---------------------------------------+
| PROJECT                | Github                                |
+------------------------+---------------------------------------+
| PLAYBOOK               | sitea-deploy.yml                      |
+------------------------+---------------------------------------+
| CREDENTIALS            | Ansible Workshop Credential           |
+------------------------+---------------------------------------+
| TAGS                   | rpm                                   |
+------------------------+---------------------------------------+
| OPTIONS                | Enable Privilege Escalation           |
+------------------------+---------------------------------------+

Select the Launch button or the Rocket Icon at the bottom of the page, then watch the Ansible output.


To confirm your playbook performed properly, use the ``curl`` command to access each Site-A server on port 8080.

.. parsed-literal::

  $ curl \http://|node_1_ip|:8080
  $ curl \http://|node_2_ip|:8080

Configuring A Job Template For Site-B
-------------------------------------

On the left hand side, select Templates.  Then select the ADD |Add button| on the top right side and select job template.

Use this information to complete the Job Template form.

+------------------------+------------------------------------------+
| NAME                   | Site-B Apache Simple Container Deploy    |
+========================+==========================================+
| DESCRIPTION            | Deploy Site-B Website                    |
+------------------------+------------------------------------------+
| JOB TYPE               | Run                                      |
+------------------------+------------------------------------------+
| INVENTORY              | Ansible Workshop Inventory               |
+------------------------+------------------------------------------+
| PROJECT                | Github                                   |
+------------------------+------------------------------------------+
| PLAYBOOK               | siteb-apache-simple-container-deploy.yml |
+------------------------+------------------------------------------+
| CREDENTIALS            | Ansible Workshop Credential              |
+------------------------+------------------------------------------+
| OPTIONS                | Enable Privilege Escalation              |
+------------------------+------------------------------------------+

Select the Launch button or the Rocket Icon at the bottom of the page, then watch the Ansible output.


To confirm your playbook performed properly, use the ``curl`` command to access each Site-A server on port 8080.

.. parsed-literal::

  $ curl \http://|node_3_ip|:8080
  $ curl \http://|node_4_ip|:8080



Configuring A Job Template For NGINX LoadBalancer
-------------------------------------------------

On the left hand side, select Templates.  Then select the ADD |Add button| on the top right side and select job template.

Use this information to complete the Job Template form.

+------------------------+------------------------------------------+
| NAME                   | Deploy NGINX LoadBalancer                |
+========================+==========================================+
| DESCRIPTION            | Deploy NGINX LoadBalancer                |
+------------------------+------------------------------------------+
| JOB TYPE               | Run                                      |
+------------------------+------------------------------------------+
| INVENTORY              | Ansible Workshop Inventory               |
+------------------------+------------------------------------------+
| PROJECT                | Github                                   |
+------------------------+------------------------------------------+
| PLAYBOOK               | nginx-lb-deploy.yml                      |
+------------------------+------------------------------------------+
| CREDENTIALS            | Ansible Workshop Credential              |
+------------------------+------------------------------------------+
| OPTIONS                | Enable Privilege Escalation              |
+------------------------+------------------------------------------+

Select the Launch button or the Rocket Icon at the bottom of the page, then watch the Ansible output.


After a successful completion, confirm your load balancer is deployed by testing by hitting the loadbalancer url and port via curl or in a web browser.

.. parsed-literal::

  $ curl \http://|control_public_ip|:8081

Summary
--------

Ansible Tower is how Ansible is consumed at enterprise scale. It provides an
API, a database that is a single source of truth, and the ability to deploy in a
highly-available mesh across your entire infrastructure. For any team managing
production environments, Ansible Tower is a vital tool.

.. |Credentials button| image:: ./_static/images/at_credentials_button.png
.. |Browse button| image:: ./_static/images/at_browse.png
.. |Submit button| image:: ./_static/images/at_submit.png
.. |Gear button| image:: ./_static/images/at_gear.png
.. |Add button| image:: ./_static/images/at_add.png
.. |Save button| image:: ./_static/images/at_save.png
.. |Source button| image:: ./_static/images/at_inv_source_button.png
