.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>
.. _docs admin: jduncan@redhat.com

==================
CI/CD essentials
==================

Overview
''''''''''

Our goal for today's lab is to help you build out a real-world example of how Ansible can be used to provide the fundamental concepts around `Continuous Integration <https://en.wikipedia.org/wiki/Continuous_integration>`__ and `Continuous Delivery <https://en.wikipedia.org/wiki/Continuous_delivery>`__ (CI/CD). To help us examine the fundamental concepts more closely, we're not going to abstract the workflow using a CI/CD platform like `Jenkins <https://jenkins.io/>`__. We're building out the steps manually today using Ansible. Our ultimate goal is to make these workflows available on-demand using `Ansible Tower <https://www.ansible.com/products/tower>`__, using Ansible best practices.

Additionally, all our workloads in this lab are  deployed using `Linux containers <https://www.redhat.com/en/topics/containers>`__. If this isn't something you've done before, don't worry. The examples are all copy/paste friendly, and the goal of a workshop like this one is to give you confidence to use tools that you haven't used before.

Common vocabulary
''''''''''''''''''''''

Let's take a few minutes to level set around some of the vocabulary we're using throughout today's lab.

Continuous Integration
```````````````````````

Continuous Integration (CI) is a development practice that requires developers to integrate code into a shared repository several times a day. Each check-in is then verified by an automated build, allowing teams to detect problems early. (`source <https://en.wikipedia.org/wiki/Continuous_integration>`__)

Continuous Delivery
`````````````````````

Continuous delivery (CD or CDE) is a software engineering approach in which teams produce software in short cycles, ensuring that the software can be reliably released at any time and, when releasing the software, doing so manually. (`source <https://en.wikipedia.org/wiki/Continuous_delivery#cite_note-CD_LC-1>`__)

Containers
```````````

Containers are applications deployed by a container runtime (``docker`` in today's lab) that are formatted using the `OCI container image format<https://github.com/opencontainers/image-spec>`__. To expose a few more of the internals, we're going to manage these containers directly instead of using a container application platform like `OpenShift <https://www.openshift.com>`__.

Ansible
````````

Ansible is the main focus of our work today. Ansible is an automation tool written in `Python <https://www.python.org>`__. We'll be interacting with Ansible using playbooks that are written using `YAML <https://yaml.org/>`__.

Ansible Tower
``````````````

Ansible Tower (Tower) is how you use Ansible at scale. Tower is a mature web application that provides a user interface, RBAC, and API in front of your Ansible workloads. For teams larger than a few people who are managing more than a few servers, Ansible Tower is the best way to use Ansible.

Getting Started
'''''''''''''''''

Ready? Let's start building out our next-generation infrastructure!
