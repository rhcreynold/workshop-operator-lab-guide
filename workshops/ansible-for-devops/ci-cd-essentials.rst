.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>
.. _docs admin: jduncan@redhat.com

==================
CI/CD Essentials
==================

Overview
''''''''''

Our goal for today's lab is to help you build out a real-world example of how Ansible can be used to provide the fundamental concepts around `Continuous Integration <https://en.wikipedia.org/wiki/Continuous_integration>`__ and `Continuous Delivery <https://en.wikipedia.org/wiki/Continuous_delivery>`__ (CI/CD). To help us examine the fundamental concepts more closely, we're not going to abstract the workflow using a CI/CD platform like `Jenkins <https://jenkins.io/>`__. We're going to build out the steps manually using Ansible directly. Our ultimate goal is to make these workflows available on-demand using `Ansible Tower <https://www.ansible.com/products/tower>`__ using Ansible best practices.

Additionally, all of our workloads in this lab are going to be deployed using `Linux containers <https://www.redhat.com/en/topics/containers>`__. If this isn't something you've done before, don't worry. The examples are all copy/paste friendly, and the goal of a workshop like this one is to give you confidence to use tools that you haven't used before.

Defining Common Terms
''''''''''''''''''''''

- Continuous Integration
- Continuous Delivery
- Containers
- Ansible
- Ansible Tower 
