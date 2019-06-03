Discussion - Protection with SELinux
=======================================

SELinux has a polarizing reputation in the Linux community. Inside an
OpenShift cluster, it is 100% required. We're not going to get into the
specifics due to time constraints, but we wanted to carve out a time for
you to ask any specific questions and to give a few highlights about
SELinux in OpenShift.

SELinux in OpenShift
'''''''''''''''''''''

1. **SELinux must be in enforcing mode in OpenShift.** This is
   *negotiable*. SELinux prevents containers from being able to
   communicate with the host in undesirable ways, as well as limiting
   cross-container resource access.
2. **SELinux requires no configuration out of the box.** You *can*
   customize SELinux in OpenShift, but it's not required at all.
3. **By default, OpenShift acts at the project level.** In order to
   provide easier communication between apps deployed in the same
   project, they share the same SELinux context by default. The
   assumption is that applications in the same project will be related
   and have a consistent need to share resources and easily communicate.

Summary
'''''''''''''''

Namespaces, CGroups, and SELinux. We know that's a lot of firehose to point at you in a single lab. These concepts are the fundamental building blocks of the container revolution that our industry is currently working through. They're also all components in Linux kernel. That's great for speed and security. But none of those things have any way of knowing what's going on in the kernel on another server.

*Real power comes when you can orchestrate containers for your applications across multiple servers. That's where OpenShift and kubernetes step in.*
