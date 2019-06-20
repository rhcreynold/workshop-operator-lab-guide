.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>
.. _docs admin: jduncan@redhat.com

========================
Introduction
========================

Thanks for making the time attending today's workshop! We hope it provides value for you.

Workshop design
----------------

Today's workshop is designed as a series of guided labs in an environment that's been deployed in Amazon ahead of time for your convenience. We'll start off today with some introductory information before we move into lab #1.

.. admonition:: But I already know about Ansible!

  We'll try to keep the intro as short as possible. We want you to get into the fun stuff in the labs! But we have to ensure that we're all using the same vocabulary to talk about the goals we have for today.

Custom lab environment
-----------------------

Your environment was custom built for you. Your lab environment is:

:Username: |student_name|
:Password: |student_pass|

=========== ========================== =============================
Node name   Purpose                    IP Address
=========== ========================== =============================
control     Primary Host/Tower Server  |control_public_ip| (public)
node1       Site A server 1            |node_1_ip|
node2       Site A server 2            |node_2_ip|
node3       Site B server 1            |node_3_ip|
node4       Site B server 2            |node_4_ip|
=========== ========================== =============================

This should be all of the information you need to manage your environment for the rest of the workshop. If a dependency is needed on a host that's not already there, we'll write some Ansible to take care of it. In the next section, we'll take care of level-setting everyone around the CI/CD concepts that we'll be using throughout the labs. Thanks again for joining us!

Goals
'''''''''''''''''

Today we're going to build out the following scenario:

- Deploy artifacts we need to use containers and Ansible effectively. We'll be
- Deploy production Site A using Ansible playbooks. Site A will be two Amazon instances, each running an ``httpd`` container running a custom website.
- Deploy and configure Ansible Tower
- Deploy production Site B using Ansible playbooks
- Configure an nginx load balancer to balance traffic between both production sites on your control node
- Tie all of this together in Ansible Tower in a single CI/CD workflow
