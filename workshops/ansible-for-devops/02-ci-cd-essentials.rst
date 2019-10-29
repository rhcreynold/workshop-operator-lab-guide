.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==================
CI/CD essentials
==================

Overview
''''''''''

Our goal for today's lab is to help you build out a real-world example of how Ansible can be used to provide the fundamental concepts around :ci_def:`Continuous Integration<>` and :cd_def:`Continuous Delivery <>` (CI/CD). To help us examine the fundamental concepts more closely, we're not going to abstract the workflow using a CI/CD platform like :jenkins:`Jenkins<>`. We're building out the steps manually today using Ansible. Our ultimate goal is to make these workflows available on-demand using :tower:`Ansible Tower<>`, using Ansible best practices.

Additionally, all our workloads in this lab are  deployed using :rh_containers:`Linux containers<>`. If this isn't something you've done before, don't worry. The examples are all copy/paste friendly, and the goal of a workshop like this one is to give you confidence to use tools that you haven't used before.

Common vocabulary
''''''''''''''''''''''

Let's take a few minutes to level set around some of the vocabulary we're using throughout today's lab.

Continuous Integration
```````````````````````

Continuous Integration (CI) is a development practice that requires developers to integrate code into a shared repository several times a day. Each check-in is then verified by an automated build, allowing teams to detect problems early. (:ci_def:`source<>`)

Continuous Delivery
`````````````````````

Continuous delivery (CD or CDE) is a software engineering approach in which teams produce software in short cycles, ensuring that the software can be reliably released at any time and, when releasing the software, doing so manually. (:cd_def:`source<>`)

Containers
```````````

Containers are applications deployed by a container runtime (``docker`` in today's lab) that are formatted using the :github:`OCI container image format<opencontainers/image-spec>`. To expose a few more of the internals, we're going to manage these containers directly instead of using a container application platform like :ocp:`OpenShift<>`.

Ansible
````````

Ansible is the main focus of our work today. Ansible is an automation tool written in :python:`Python<>`. We'll be interacting with Ansible using playbooks that are written using :yaml:`YAML<>`.

Ansible Tower
``````````````

Ansible Tower (Tower) is how you use Ansible at scale. Tower is a mature web application that provides a user interface, RBAC, and API in front of your Ansible workloads. For teams larger than a few people who are managing more than a few servers, Ansible Tower is the best way to use Ansible.

Getting Started
'''''''''''''''''

Ready? Let's start building out our next-generation infrastructure!
