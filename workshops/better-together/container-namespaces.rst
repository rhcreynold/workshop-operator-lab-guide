Lab 3 - Containers are Linux
================================================

You can find five different container experts and ask them to define
what a container is, and you're likely to get five different answers.
The following are some of our personal favorites, all of which are
correct from a certain perspective:

-  A transportable unit to move applications around. This is a typical
   developer's answer.
-  A fancy Linux process (one of our personal favorites)
-  A more effective way to isolate processes on a Linux system. This is
   a more operations-centered answer.

More effective process isolation
`````````````````````````````````

.. important::

  For this section, SSH to your infrastructure node so you can inspect the containers directly.


We mentioned in the last section that containers utilize server
resources more effectively than VMs (the previous most effective
resource isolation method). The primary reason is because containers use
different systems in the Linux kernel to isolate the processes inside
them. These systems don't need to utilize a full virtualized kernel like
a VM does.

.. figure:: images/ops/vm_vs_container.png
   :alt: VM vs Container
   :captions: VM versus containers

Let's investigate what makes a container a container.

Isolation with kernel namespaces
''''''''''''''''''''''''''''''''''''''''

The kernel component that makes the applications feel isolated are
called *namespaces*. Namespaces are a lot like a two-way mirror or a
paper wall inside Linux. Like a two-way mirror, from the host we can see
inside the container. But from inside the container it can only see
what's inside its namespace. And like a paper wall, namepsaces provide
sufficient isolation but they're lightweight to stand up and tear down.

On your infrastructure node, log in as your student user and run the
``sudo lsns`` command. The output will be long, so let's look at the
content towards the bottom.

::

    $ sudo lsns
    NS TYPE  NPROCS   PID USER       COMMAND
    ...
    4026533100 mnt        2 33456 ec2-user   /bin/sh /opt/eap/bin/standalone.sh -Djavax.net.s
    4026533101 uts        2 33456 ec2-user   /bin/sh /opt/eap/bin/standalone.sh -Djavax.net.s
    4026533102 pid        2 33456 ec2-user   /bin/sh /opt/eap/bin/standalone.sh -Djavax.net.s
    4026533103 mnt        1 33536 ec2-user   heapster --source=kubernetes.summary_api:${MASTE
    4026533104 uts        1 33536 ec2-user   heapster --source=kubernetes.summary_api:${MASTE
    4026533105 pid        1 33536 ec2-user   heapster --source=kubernetes.summary_api:${MASTE
    4026533106 mnt        5 35429 1000080000 /bin/bash /opt/app-root/src/run.sh
    4026533107 mnt        1 34734 student1   /usr/bin/pod
    4026533108 uts        1 34734 student1   /usr/bin/pod
    4026533109 ipc        7 34734 student1   /usr/bin/pod
    ...

To limit this content to a single process, specify one of the PIDs on
your system by using the ``-p`` parameter for ``lsns``.

::

  $ sudo lsns -p34734
  NS TYPE  NPROCS   PID USER     COMMAND
  4026531837 user     210     1 root     /usr/lib/systemd/systemd --switched-root --system
  4026533107 mnt        1 34734 student1 /usr/bin/pod
  4026533108 uts        1 34734 student1 /usr/bin/pod
  4026533109 ipc        7 34734 student1 /usr/bin/pod
  4026533110 pid        1 34734 student1 /usr/bin/pod
  4026533112 net        7 34734 student1 /usr/bin/pod

Let's discuss 5 of these namespaces.

The mount namespace
````````````````````

The mount namespace is used to isolate filesystem resources inside
containers. The files inside the base image used to deploy a container.
From the point of view of the container, that's all that is available or
visible.

.. admonition:: Persistent storage and host resources

  If your container has host resources or persistent storage assigned to
  it, these are made available using a `Linux bind
  mount <https://unix.stackexchange.com/questions/198590/what-is-a-bind-mount>`__.
  This means, not matter what you use for your persistent storage backed,
  your developer's applications only ever need to know how to access the
  correct directory.

We can see this using the ``nsenter`` command line utility on your
infrastructure node. ``nsenter`` is used to enter a single namespace
that is associated with another PID. When debugging container
environments, its value is massive. Here is the root filesystem listing
from an infrastructure node.

::

  $ sudo ls -al /
  total 24
  dr-xr-xr-x.  18 root root  236 Nov  9 08:09 .
  dr-xr-xr-x.  18 root root  236 Nov  9 08:09 ..
  lrwxrwxrwx.   1 root root    7 Nov  9 08:09 bin -> usr/bin
  dr-xr-xr-x.   5 root root 4096 Nov  9 08:13 boot
  drwxr-xr-x.   2 root root    6 Nov 18  2017 data
  drwxr-xr-x.  18 root root 2760 Nov  9 08:13 dev
  drwxr-xr-x. 107 root root 8192 Nov  9 09:02 etc
  drwxr-xr-x.   4 root root   38 Dec 14  2017 home
  lrwxrwxrwx.   1 root root    7 Nov  9 08:09 lib -> usr/lib
  lrwxrwxrwx.   1 root root    9 Nov  9 08:09 lib64 -> usr/lib64
  drwxr-xr-x.   2 root root    6 Dec 14  2017 media
  drwxr-xr-x.   2 root root    6 Dec 14  2017 mnt
  ...

After using ``nsenter`` to enter the mount namespace for the hawkular
container (hawkular is part of the metrics gather system in OpenShift),
you see that the root filesystem is different.

::

  $ sudo nsenter -m -t 33154[root@ip-172-16-87-199 /]# ll
  total 0
  lrwxrwxrwx.   1 root root         7 Aug  1 13:02 bin -> usr/bin
  dr-xr-xr-x.   2 root root         6 Dec 14  2017 boot
  drwxrwsrwx.   4 root 1000040000  61 Nov  9 14:07 cassandra_data
  drwxr-xr-x.   5 root root       360 Nov  9 14:07 dev
  drwxr-xr-x.   1 root root        66 Nov  9 14:07 etc
  drwxrwsrwt.   3 root 1000040000 160 Nov  9 14:04 hawkular-cassandra-certs
  drwxr-xr-x.   1 root root        23 Sep 17 18:44 home
  lrwxrwxrwx.   1 root root         7 Aug  1 13:02 lib -> usr/lib
  lrwxrwxrwx.   1 root root         9 Aug  1 13:02 lib64 -> usr/lib64
  drwxr-xr-x.   2 root root         6 Dec 14  2017 media
  ...

The container image for hawkular includes some of the fileystem like a
normal server, but it also includes directories that are specific to the
application.

The uts namespace
``````````````````

UTS stands for "Unix Time Sharing". This is a concept that has been
around since the 1970's when it was a novel idea to allow multiple users
to log in to a system simultaneously. If you run the command
``uname -a``, the information returned is the UTS data structure from
the kernel.

::

    $ uname -a
    Linux ip-172-16-87-199.ec2.internal 3.10.0-957.el7.x86_64 #1 SMP Thu Oct 4 20:48:51 UTC 2018 x86_64 ...

Each container in OpenShift gets its own UTS namespace, which is
equivalent to its own ``uname -a`` output. That means each container
gets its own hostname and domain name. This is extremely useful in a
large distributed application platform like OpenShift.

We can see this in action using ``nsenter``.

::

    $ hostname
    ip-172-16-87-199.ec2.internal
    $ sudo nsenter -u -t 33154
    [root@hawkular-cassandra-1-w2vqb student1]# hostname
    hawkular-cassandra-1-w2vqb

The ipc namespace
``````````````````

The IPC (inter-process communication) namespace is dedicated to kernel
objects that are used for processes to communicate with each other.
Objects like named semaphores and shared memory segments are included.
here. Each container can have its own set of named memory resources and
it won't conflict with any other container or the host itself.

The pid namespace
```````````````````

In the Linux world, PID 1 is an important concept. PID 1 is the process
that starts all the other processes on your server. Inside a container,
that is true, but it's not the PID 1 from your server. Each container
has its own PID 1 thanks to the PID namespace. From our host, we see all
of the processes we would expect on a Linux server using ``pstree``.

.. admonition:: Privileged containers

  Most of the containers are your infrastructure node run in privileged
  mode. That means these containers have access to all or some of the
  host's namespaces. This is a useful, but powerful tool reserved for
  applications that need to access a host's filesystem or network stack
  (or other namespaced components) directly. The example below is from an
  unprivileged container running an Apache web server.

::

    # ps --ppid 4470
       PID TTY          TIME CMD
      4506 ?        00:00:00 cat
      4510 ?        00:00:01 cat
      4542 ?        00:02:55 httpd
      4544 ?        00:03:01 httpd
      4548 ?        00:03:01 httpd
      4565 ?        00:03:01 httpd
      4568 ?        00:03:01 httpd
      4571 ?        00:03:01 httpd
      4574 ?        00:03:00 httpd
      4577 ?        00:03:01 httpd
      6486 ?        00:03:01 httpd

When you execute the same command from inside the PID namespace, you see
a different result. For this example, instead of using ``nsenter``,
we'll use the ``oc exec`` command from our control node. It does the
same thing, with the primary difference being that we don't need to know
the application node the container is deployed to, or its actual PID.

::

    $ oc exec app-cli-4-18k2s ps
       PID TTY          TIME CMD
         1 ?        00:00:27 httpd
        18 ?        00:00:00 cat
        19 ?        00:00:01 cat
        20 ?        00:02:55 httpd
        22 ?        00:03:00 httpd
        26 ?        00:03:00 httpd
        43 ?        00:03:00 httpd
        46 ?        00:03:01 httpd
        49 ?        00:03:01 httpd
        52 ?        00:03:00 httpd
        55 ?        00:03:00 httpd
        60 ?        00:03:01 httpd
        83 ?        00:00:00 ps

From the point of view of the server, PID 4470 is an ``httpd`` process
that has spawned several child processes. Inside the container, however,
the same ``httpd`` process is PID 1, and its PID namespace has been
inherited by its child processes.

PIDs are how we communicate with processes inside Linux. Each container
having its own set of Process IDs is important for security as well as
isolation.

The network namespace
``````````````````````

OpenShift relies on software-defined networking that we'll discuss more
in an upcoming section. Because of this, as well as modern networking
architectrues, the networking configuration on an OpenShift node can
become extremely complex. One of the over-arching goals of OpenShift is
to make the devloper's experience consistent no matter the underlying
host's complexity. The network namespace helps with this. On your
infrastructure node, there could be upwards of 20 defined interaces.

::

    $ ip a
    1: lo: <loopback,up,lower_up> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host
           valid_lft forever preferred_lft forever
    2: eth0: <broadcast,multicast,up,lower_up> mtu 9001 qdisc mq state UP group default qlen 1000
        link/ether 0e:39:78:cc:a6:58 brd ff:ff:ff:ff:ff:ff
        inet 172.16.87.199/16 brd 172.16.255.255 scope global noprefixroute dynamic eth0
           valid_lft 3178sec preferred_lft 3178sec
        inet6 fe80::c39:78ff:fecc:a658/64 scope link
           valid_lft forever preferred_lft forever
    3: docker0: <no-carrier,broadcast,multicast,up> mtu 1500 qdisc noqueue state DOWN group default
        link/ether 02:42:36:9f:24:e7 brd ff:ff:ff:ff:ff:ff
        inet 172.17.0.1/16 scope global docker0
           valid_lft forever preferred_lft forever
    4: ovs-system: <broadcast,multicast> mtu 1500 qdisc noop state DOWN group default qlen 1000
        link/ether f6:95:72:0e:09:4f brd ff:ff:ff:ff:ff:ff
    5: br0: <broadcast,multicast> mtu 8951 qdisc noop state DOWN group default qlen 1000
        link/ether be:47:c6:da:e5:48 brd ff:ff:ff:ff:ff:ff
    6: vxlan_sys_4789: <broadcast,multicast,up,lower_up>mtu 65000 qdisc noqueue master ovs-system state UNKNOWN group default qlen 1000
        link/ether 7a:0b:31:e4:a4:eb brd ff:ff:ff:ff:ff:ff
        inet6 fe80::780b:31ff:fee4:a4eb/64 scope link
           valid_lft forever preferred_lft forever
    ...</broadcast,multicast,up,lower_up> </broadcast,multicast></broadcast,multicast></no-carrier,broadcast,multicast,up></broadcast,multicast,up,lower_up></loopback,up,lower_up>

However, from within one of the containers on that node, you only see an
``eth0`` and ``lo`` infterface.

::

    $ sudo nsenter -n -t 29774 ip a
    1: lo: <loopback,up,lower_up> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host
           valid_lft forever preferred_lft forever
    3: eth0@if10: <broadcast,multicast,up,lower_up>mtu 8951 qdisc noqueue state UP group default
        link/ether 0a:58:0a:81:00:04 brd ff:ff:ff:ff:ff:ff link-netnsid 0
        inet 10.129.0.4/23 brd 10.129.1.255 scope global eth0
           valid_lft forever preferred_lft forever
        inet6 fe80::d0c8:ecff:fe7a:4049/64 scope link
           valid_lft forever preferred_lft forever</broadcast,multicast,up,lower_up> </loopback,up,lower_up>

Each container's network namespace has a single outbound interface
(eth0) and a loopback address (lots of applications like to use the
loopback interface). We'll cover OpenShift SDN (the software-defined
network configuration in OpenShift) and how traffic gets from the
interface inside a container out to its destination in an upcoming
section.

.. admonition:: What about the User namespace?

  Currently in OpenShift, all containers share a single user namespace.
  This is due to some lingering performance issues with the user namespace
  that prevent it from being capable of handling the enterpise scale that
  OpenShift is designed for. Don't worry, we're working on it.

  User namespaces are utilized in `Podman rootless mode <https://opensource.com/article/19/2/how-does-rootless-podman-work>`__.

Summary
''''''''''
Linux kernel namespaces are used to isolate processes running inside
containers. They're more lightweight than virtualization technologies and
don't require an entire virtualized kernel to function properly. From
inside a container, namespaced resources are fully isolated, but can
still be viewed and accessed when needed from the host and from
OpenShift.
