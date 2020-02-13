.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==========================================
Inventories, Source code and container repositories
==========================================

Overview
---------

In this lab we're using Github account :github:`github.com<>` to provide version control for the playbooks and roles we'll create. Additionally we'll use Quay.io account :quay:`quay.io<>` registry to house our container images. Our tasks for this lab are to:

1. Set up an group in your inventory file
2. Configure Github and confirm it's functioning properly
3. Configure Quay.io and confirm it's functioning properly


Let's get started.

Adding inventory groups
------------------------

You need to add a ``nodes`` group to your inventory located at ``~/ansible-for-devops-workshop/hosts``. First let's create the hosts file.

.. code-block:: bash

  $ mkdir ~/ansible-for-devops-workshop/
  $ vim ~/ansible-for-devops-workshop/hosts

Add your ``nodes`` groups to ``~/ansible-for-devops-workshop/hosts``.

.. parsed-literal::

  [nodes]
  |node_1_ip|
  |node_2_ip|
  |node_3_ip|
  |node_4_ip|


Creating a Github repository
```````````````````````````

To create our initial github repository, we'll first create one in the Github UI, then add our content so far to it and upload to our remote host.

The first step is to create a new repository in the Github UI :github:`github.com<>`. After logging in with , click |plus sign| on the top right side of the screen.

Adding a new repository to Github
````````````````````````````````

This takes you to the new repository wizard. We only need to fill out a name (``ansible-for-devops-workshop``) and description for our repository.  You can keep the repository public.

After this is filled out, click Create Repository Button. This will create your new repository and take you to its dashboard page.  You should see the output below

.. code-block:: bash

  echo "# ansible-for-devops-workshop" >> README.md
  git init
  git add README.md
  git commit -m "first commit"
  git remote add origin https://github.com/|student_name|/ansible-for-devops-workshop.git
  git push -u origin master

With this complete, we'll use the cli to create a new repository and make it a git repository with our new repository set as the origin for it.

Creating a git repository from existing files
``````````````````````````````````````````````

On your control node, ``cd`` to your ``ansible-for-devops-workshop`` directory

.. code-block:: bash

  cd ~/ansible-for-devops-workshop

From this directory, follow the directions from the github repository creation dashboard output from section the section above. We'll make a few small changes in those instructions is to add all of the existing files instead of just the example ``README.md`` as well as to configure a username and email for your commit.

.. admonition:: What about README.md

  The ``README.md`` file is optional for this workshop, but is definitely a best practice in general. 

.. parsed-literal::
  $ echo "# ansible-for-devops-workshop" >> README.md
  $ git init
  Initialized empty Git repository in /home/|student_name|/ansible-for-devops-workshop/.git/
  $ git add .
  $ git config --global user.email "GITHUB EMAIL"
  $ git config --global user.name |student_name|
  $ git commit -m "first commit"
  [master (root-commit) 9b28318] first commit
   2 files changed, 6 insertions(+)
   create mode 100644 README.md
   create mode 100644 hosts
  $ git remote add origin https://github.com/|student_name|/ansible-for-devops-workshop.git
  $ git push -u origin master
  Enumerating objects: 4, done.
  Counting objects: 100% (4/4), done.
  Delta compression using up to 12 threads
  Compressing objects: 100% (2/2), done.
  Writing objects: 100% (4/4), 307 bytes | 307.00 KiB/s, done.
  Total 4 (delta 0), reused 0 (delta 0)
  To https://github.com/|student_name|/ansible-for-devops-workshop.git
   * [new branch]      master -> master
  Branch 'master' set up to track remote branch 'master' from 'origin'.

You'll be prompted for your GitHub username and password you set up when you registered. And that's it.  To confirm your work was successful, reload your repository dashboard in Github and you should see the files that were just committed.


Creating your container registry
--------------------------------

You'll need to log into Quay.io :quay:`quay.io<>` to create the repository that we are going to use today.  At the top right of the screen click the |plus sign| and select ``New Repository``.

In the ``Create New Repository`` page, we will need to make a few changes.  First let's give the repository a name. We are going to use ``ansible-for-devops-siteb``.

Next we will select the ``Public`` radio button.  This will allow anyone to see and pull from the repository.  Also it is free :)

For the final selection we will ``(Empty Repository)`` and select ``Create Public Repository`` button.

And now your system is ready for the rest of the workshop!

Summary
--------

This lab setups and configures your environment to work with the fundamental building blocks that make DevOps possible. Everything you do should be in source control. Additionally, containers are the building blocks of modern infrastructure as you will see in the upcoming labs.

.. |plus sign| image:: _static/images/gogs_plus.png
.. |save button| image:: _static/images/gogs_save.png
