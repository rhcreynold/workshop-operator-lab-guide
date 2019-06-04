Lab 4 - Quotas and Limits
=====================================================

In this lab we'll investigate how the Linux kernel uses Control Groups to prevent containers from consuming more than their fair share of host resources.

.. important::

  For this lab, SSH to your master node and escalate to your root user so you can interact with OpenShift via the ``oc`` command line client.

What are kernel control groups?
''''''''''''''''''''''''''''''''

Kernel Control Groups are how containers (and other things like VMs and
even clever sysadmins) limit the resources available to a given process.
Nothing fixes bad code. But with control groups in place, it can become
restarting a single service when it crashes instead of restarting the
entire server.

In OpenShift, control groups are used to deploy resource limit and
requests. Let's set up some limits for applications in a new project
that we'll call ``image-uploader``. Let's create a new project using our
control node.

.. admonition:: Why do I need to be the root user on the control node?

  When it deploys, OpenShift places a special certificate in
  ``/root/.kube/config``. This certificate allows you to access OpenShift
  as full admin without needing to log in.

Creating projects
''''''''''''''''''

Applications deployed in OpenShift are separated into *projects*.
Projects are used not only as logical separators, but also as a
reference for RBAC and networking policies that we'll discuss later. To
create a new project, use the ``oc new-project`` command.

::

    # oc new-project image-uploader --display-name="Image Uploader Project"
    Now using project "image-uploader" on server "https://ip-172-16-129-11.ec2.internal:443".

    You can add applications to this project with the 'new-app' command. For example, try:

        oc new-app centos/ruby-22-centos7~https://github.com/openshift/ruby-ex.git

    to build a new example application in Ruby.

We'll use this project for multiple examples. Before we actually deploy
an application into it, we want to set up project limits and requests.

Limits and Requests
''''''''''''''''''''


OpenShift Limits are per-project maximums for various objects like
number of containers, storage requests, etc. Requests for a project are
default values for resource allocation if no other values are requested.
We'll work with this more in a while, but in the meantime, think of
Requests as a lower bound for resources in a project, while Limits are
the upper bound.

Creating Limits and Requests for a project
'''''''''''''''''''''''''''''''''''''''''''


The first thing we'll create for the Image Uploader project is a
collection of Limits. This is done, like most things in OpenShift, by
creatign a YAML file and having OpenShift process it. On your control
node, create a file named ``/root/core-resource-limits.yaml``. It should
contain the following content.

::

    apiVersion: "v1"
    kind: "LimitRange"
    metadata:
      name: "core-resource-limits"
    spec:
      limits:
        - type: "Pod"
          max:
            cpu: "2"
            memory: "1Gi"
          min:
            cpu: "100m"
            memory: "4Mi"
        - type: "Container"
          max:
            cpu: "2"
            memory: "1Gi"
          min:
            cpu: "100m"
            memory: "4Mi"
          default:
            cpu: "300m"
            memory: "200Mi"
          defaultRequest:
            cpu: "200m"
            memory: "100Mi"
          maxLimitRequestRatio:
            cpu: "10"

After your file is created, have it processed and added to the
configuration for the ``image-uploader`` project.

::

    # oc create -f core-resource-limits.yaml -n image-uploader
    limitrange "core-resource-limits" created

To confirm your limits have been applied, run the ``oc get limitrange``
command.

::

    # oc get limitrange
    NAME                   AGE
    core-resource-limits   2m

The ``limitrange`` you just created applies to any applications deployed
in the ``image-uploader`` project. Next, you're going to create resource
limits for the entire project. Create a file named
``/root/compute-resources.yaml`` on your control node. It should contain
the following content.

::

    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: compute-resources
    spec:
      hard:
        pods: "10"
        requests.cpu: "2"
        requests.memory: 2Gi
        limits.cpu: "3"
        limits.memory: 3Gi
      scopes:
        - NotTerminating

Once it's created, apply the limits to the ``image-uploader`` project.

::

    # oc create -f compute-resources.yaml -n image-uploader
    resourcequota "compute-resources" created

Next, confirm the limits were applied using ``oc get``.

::

    # oc get resourcequota -n image-uploader
    NAME                AGE
    compute-resources   1m

We're almost done! So fare we've define resource limits for both apps
and the entire ``image-uploader`` project. These are controlled under
the convers by control groups in the Linux kernel. But to be safe, we
also need to define limits to the numbers of kubernetes objects that can
be deployed in the ``image-uploader`` project. To do this, create a file
named ``/root/core-object-counts.yaml`` with the following content.

::

    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: core-object-counts
    spec:
      hard:
        configmaps: "10"
        persistentvolumeclaims: "5"
        resourcequotas: "5"
        replicationcontrollers: "20"
        secrets: "50"
        services: "10"
        openshift.io/imagestreams: "10"

Once created, apply these controls to your ``image-uploader`` project.

::

    # oc create -f core-object-counts.yaml -n image-uploader
    resourcequota "core-object-counts" created

If you re-run ``oc get resourcequota``, you'll see both quotas applied
to your ``image-uploader`` project.

::

    # oc get resourcequota -n image-uploader
    NAME                 AGE
    compute-resources    9m
    core-object-counts   1m

Summary
''''''''

The resource guardrails provided by control groups inside OpenShift are
invaluable to an Ops team. We can't run around looking at every
container that comes or go. We have to be able to programatically define
flexible quotas and requests for our developers. All of this information
is available in the OpenShift web interface, so your devs have no excuse
for not knowing what they're using and how much they have left.
