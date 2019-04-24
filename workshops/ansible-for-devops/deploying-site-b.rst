.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>
.. _docs admin: jduncan@redhat.com

==================
Deploying Site B
==================
Overview
`````````

We have gone ahead and stood up two additional Red Hat Enterprise Linux hosts for you.  In this lab we are going to
deploy a containerized simple web application (from an Ansible Role) on two different hosts. This will host a simple
website display the hostname.

Let first modify the ``hosts`` file and add the correct ip addresses for our web servers.

.. parsed-literal::
  [gogs]
  |control_public_ip|

  [site1]
  |node_1_ip|
  |node_2_ip|

  [site2]
  |node_3_ip|
  |node_4_ip|
