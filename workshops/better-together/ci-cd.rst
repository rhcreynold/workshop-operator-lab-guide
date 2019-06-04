Lab 8 - A real world CI/CD scenario
====================================

In the final section of our workshop, we'll take everything we've been
discussing and put it into practice with a large, complex, real-work
workflow. In your cluster, you'll create multiple projects and use a
Jenkins pipeline workflow that:

-  Checks out source code from a git server within Openshift
-  Builds a java application and archives it in Nexus
-  Runs unit tests for the application
-  Runs code analysis using Sonarqube
-  Builds a Wildfly container image
-  Deplous the app into a dev project and runs integration tests
-  Builds a human break into the OpenShift UI to confirm before it
   promotes the application to the stage project

.. important::

 For this lab, SSH to your master node and escalate to your root user so you can interact with OpenShift via the ``oc`` command line client.

This is a complete analog to a modern CI/CD workflow, implemented 100%
within OpenShift. First, we'll need to create some projects for your
CI/CD workflow to use. The content can be found on Github at
https://github.com/siamaksade/openshift-cd-demo. This content has been
downloaded already to your OpenShift control node at
``/root/cicd-demo``.

Creating a CI/CD workflow manually
''''''''''''''''''''''''''''''''''''''''

Creating the needed projects
''''''''''''''''''''''''''''''''''''

On your control node, execute the following code:

::

  oc new-project dev --display-name="Tasks - Dev"
  oc new-project stage --display-name="Tasks - Stage"
  oc new-project cicd --display-name="CI/CD"``

This will create three projects in your OpenShift cluster.

-  **Tasks - Dev:** This will house your dev team's development
   deployment
-  **Tasks - Stage:** This will be your dev team's Stage deployment
-  **CI/CD:** This projects houses all of your CI/CD tools

Giving your CI/CD project the proper permissions
''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Next, you need to give the CI/CD project permission to exexute tasks in
the Dev and Stage projects.

::

    oc policy add-role-to-group edit system:serviceaccounts:cicd -n dev
    oc policy add-role-to-group edit system:serviceaccounts:cicd -n stage

4.1.3 - Deploying your workflow

With your projects created, you're ready to deploy the demo and trigger
the workflow

::

    oc new-app -n cicd -f cicd-template.yaml --param=DEPLOY_CHE=true

This process doesn't take much time for a single application, but it
doesn't scale well, it's not repeatable, and it relies on the person
executing it knowing the commands, and the specific information about
the situation. In the next section, we'll accomplish the same thing with
a simple Ansible playbook, executed from your bastion host.

Automating application deployment with Ansible
''''''''''''''''''''''''''''''''''''''''''''''''''''

There modules for ``oc``. However, lots of interactions with OpenShift
that you'll find in OpenShift playbooks still use the ``command``
module. There is minimal risk here because the ``oc`` command itself is
idempotent.

A playbook that would create the entire CI/CD workflow could look as
follows:

::

    ---
    name: Deploy OpenShift CI/CD Project and begin workflow
    hosts: masters
    become: yes

    tasks:
    - name: Create Tasks project
      command: oc new-project dev --display-name="Tasks - Dev"
    - name: Create Stage project
      command: oc new-project stage --display-name="Tasks - Stage"
    - name: Create CI/CD project
      command: oc new-project cicd --display-name="CI/CD"
    - name: Set serviceaccount status for CI/CD project for dev and stage projects
      command: oc policy add-role-to-group edit system:serviceaccounts:cicd -n {{ item }}
      with_items:
      - dev
      - stage
    - name: Start application deployment to trigger CI/CD workflow
      command: oc new-app -n cicd -f cicd-template.yaml --param=DEPLOY_CHE=true

This playbook is relatively simple, with a single ``with_items`` loop.
What sort of additional enhancements can you think of to make this
playbook more powerful to deploy workflows inside OpenShift?

Summary
'''''''''''''

This project takes multiple complex developer tools and integrates into
a single automated workflow. Applications are built, tested, deployed,
and then humans can verify eveything passes to their satisfaction before
the final button is pushed to promote the application to the next level.
Every one of those tools is running in a container inside your OpenShift
cluster.
