OpenShift Architecture
=======================

In this section we'll discuss the fundamental components that make up
OpenShift. Any Ops-centric discussion of an application platform like
OpenShift needs to start with containers; both technically and from a
perspective of value. We'll start off talking about why containers are
the best solution today to deliver your applications.

We promise to not beat you up with slides after this, but we do have a
few more. Let's use the `OpenShift Technical
Overview <https://s3.amazonaws.com/openshift-ansible-workshop-materials/openshift_technical_overview.pdf>`__
to become familiar with the core OpenShift concepts before we dive down
into the fun details.

The value of containers
'''''''''''''''''''''''''''''

At their heart, containers are the next evolution in how we isolate
processes on a Linux system. This evolution started when we created the
first computers. They evolved from ENIAC, through mainframes, into the
server revolution all the way through virtual machines (VMs) and now
into containers.

.. figure:: images/ops/evolution.png
   :alt:

More efficient application isolation (we'll get into how that works in
the next section) provides an Ops team a few key advantages that we'll
discuss next.

Worst Case Scenario provisioning
''''''''''''''''''''''''''''''''''''''''

Think about your traditional virtualization platform, or your workflow
to deploy instances to your public cloud of choice for a moment. How big
is your default VMDK for your root OS disk? How much extra storage do
you add to your EC2 instance, just to handle the 'unknown' situations?
Is it 40GB? 60GB?

**This phenomenon is known as *Worst Case Scenario Provisioning*.** In
the industry, we've done it for years because we consider each VM a
unique creature that is hard to alter once created. Even with more
optimized workflows in the public cloud, we hold on to IP addresses, and
their associated resources, as if they're immutable once created. It's
easier to overspend on compute resources for most of us than to change
an IP address in our IPAM once we've deployed a system.

Comparing VM and Container resource usage
'''''''''''''''''''''''''''''''''''''''''''''''''

In this section we're going to investigate how containers use your
datacenter resources more efficiently. First, we'll focus on storage.

Storage resource consumption
`````````````````````````````


Compared to a 40GB disk image, the RHEL 7 container base image is
`approximately
72MB <https://access.redhat.com/containers/?tab=overview#/registry.access.redhat.com/rhel7>`__.
It's a widely accepted rule of thumb that container images shouldn't
exceed 1GB in size. If your application takes more than 1GB of code and
libraries to run, you likely need to re-think your plan of attack.

Instead of each new instance of an application consuming 40GB+ on your
storage resources, they consume a couple hundred MegaBytes. Your next
storage purchase just got a whole lot more interesting.

CPU and RAM resource consumption
`````````````````````````````````

It's not just storage where containers help save resources. We'll
analyze this in more depth in the next section, but we want to get the
idea into your head for that part of our investigation now. Containers
are smaller than a full VM because containers don't each run their own
Linux kernel. All containers on a host share a single kernel. That means
a container just needs the application it needs to execute and its
dependencies. You can think of containers as a "portable userspace" for
your applications.

.. admonition:: Time and Resource Savings

  Because each container doesn't require its own kernel, we also measure
  startup time in milliseconds! This gives us a whole new way to think
  about scalability and High Availability!

  In your cluster, log in as the admin user and navigate to the default
  project. Look at the resources your registry and other deployed
  applications consume. For example the ``registry-console`` application
  (a UI to see and manage the images in your OpenShift cluster) is
  consuming less than 3MB of RAM!

.. figure:: images/ops/metrics.jpeg
   :alt:

If we were deploying this application in a VM we would spend multiple
gigabytes of our RAM just so we could give the application the handful
of MegaBytes it needs to run properly.

The same is true for CPU consumption. In OpenShift, we measure and
allocate CPUs by the *millicore*, or thousandth of a core. Instead of
multiple CPUs, applications can be given the small fractions of a CPU
they need to get their job done.

Summary
'''''''''''''''

Containers aren't just a tool to help developers create applications
more quickly. Although they are revolutionary in how they do that.
Containers are just marketing hype. Although there's certainly a lot of
that going on right now, too.

For an Ops team, containers take any application and deploy it more
efficiently in our infrastructure. Instead of measuring each application
in GB used and full CPUs allocated, we measure containers using MB of
storage and RAM and we allocate thousandths of CPUs.

OpenShift deployed into your existing datacenter gives you back
resources. For customers deep into their transformation with OpenShfit,
an exponential increase in resource density isn't uncommon.
