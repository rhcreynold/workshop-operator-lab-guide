.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

========================
Introduction
========================

Thanks for making the time attending today's workshop! We hope it provides value for you. All of the workshop content is deployed in :aws:`AWS<ec2>`. To participate in the workshop you'll need a laptop with the following capabilities:

- Browse to public IP addresses without interference
- SSH to public IP addresses without interference
- Github account :github:`github.com<join>`
- Quay.io account :quay:`quay.io<signin>`


Workshop design
----------------

Today's workshop is designed as a series of guided labs. We'll start off today with some introductory information before we move into lab #1.

.. admonition:: But I already know about Ansible!

  We'll try to keep the intro as short as possible. We want to get into the fun stuff in the labs as quickly as possible! But we have to ensure we're all using the same vocabulary to talk about the goals we have for today.

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

Success Criteria
'''''''''''''''''

We want the lab today to be a fair analogue of what you may be doing in your own environments today with containers. By the end of today's workshop our goal is to:

- Deploy the tools we need to use containers and Ansible effectively in our infrastructure, including:

  * A :quay:`quay.io<repository>` repository to house your custom container images
  * :tower:`Ansible Tower<>` to provide a central point of automation


- Deploy to Site B using Ansible playbooks and traditional software RPM packages. Site B is a cluster of two RHEL instances on :aws:`AWS<ec2>` and serving a custom website with ``httpd``.
- Deploy to Site A using Ansible playbooks. Site A will be a cluster of two Amazon instances as well, each running ``httpd`` in containers running a custom website.
- Deploy and configure Ansible Tower
- Configure a containerized ``nginx`` load balancer to balance traffic for your development and production clusters
- Tie all of these resources together in :tower:`Ansible Tower<>` using a CI/CD workflow

.. admonition:: Copy and Paste

  Don't do it.  The formatting in this workshop is correct to display in the browser, but not for pasting into vi/vim.
