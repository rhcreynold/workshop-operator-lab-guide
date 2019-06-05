.. Workshop Lab Guide documentation master file, created by
   sphinx-quickstart on Thu Mar 28 23:19:41 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>

==============================================================
Better Together: OpenShift and Ansible Workshop Ops Lab Guide
==============================================================

Welcome
========

Thank you for joining us today at the Better Together: OpenShift and Ansible Workshop. As a reminder, here's the login information you'll use for the rest of today's lab.

- SSH Username: |student_name|
- OpenShift Username: admin and |student_name|
- Password: |student_pass|
- Control Node: |control_public_ip|

Introduction and getting started
=================================

Thank you for taking the time to come and work with us today! Let's get started.

Links and resources
-----------------------------

- `Ansible Essentials slides </_static/ansible-essentials.html>`__
- `OpenShift Technical overview slides </_static/openshift_technical_overview.pdf>`__
- `CI/CD Pipeline Example <https://github.com/siamaksade/openshift-cd-demo>`__
- `PuTTY for Windows <https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe>`__
- `Ansible Docs <https://docs.ansible.com/>`__
- `Ansible Module Index <https://docs.ansible.com/ansible/latest/modules/modules_by_category.html>`__
- `OpenShift Docs <https://docs.openshift.com/>`__
- `OC Command line client <https://github.com/openshift/origin/releases/latest>`__
- `Lab Guide Container Image <https://quay.io/repository/jduncan/operator-workshop-lab-guide-better-together>`__
- `Lab Guide Source Code <https://github.com/jduncan-rva/workshop-operator-lab-guide>`__
- `Workshop Deploy Playbooks <https://github.com/jduncan-rva/linklight-ocp>`__

.. toctree::
  :maxdepth: 2
  :numbered:
  :Caption: Index
  :name: mastertoc

  ansible-intro
  ocp-intro
  integration
  container-registry
  container-namespaces
  container-cgroups
  container-selinux
  ocp-deploying-apps
  ocp-sdn
  ocp-routing
  ci-cd
