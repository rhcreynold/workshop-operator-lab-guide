Lab 6 - OpenShift SDN
=======================

Overview
'''''''''
OpenShift uses a complex software-defined network solution using `Open
vSwitch (OVS) <https://www.openvswitch.org/>`__ that creates multiple
interfaces for each container and routes traffic through VXLANs to other
nodes in the cluster or through a TUN interface to route out of your
cluster and into other networks.

.. important::

  For this lab, SSH to your master node and escalate to your root user so you can interact with OpenShift via the ``oc`` command line client.

Inspecting the SDN
'''''''''''''''''''

At a fundamental level, OpenShift creates an OVS bridge and attaches a
TUN and VXLAN interface. The VXLAN interface routes requests between
nodes on the cluster, and the TUN interface routes traffic off of the
cluster using the node's default gateway. Each container also cretes a
``veth`` interface that is linked to the ``eth0`` interface in a
specific container using `kernel interrface
linking <https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-class-net>`__.
You can see this on your nodes by running the ``ovs-vsct list-br``
command.

.. code-block:: bash

  # ovs-vsctl list-br br0

This lists the OVS bridges on the host. To see the interfaces within the
bridge, run the following command. Here you can see the ``vxlan``,
``tun``, and ``veth`` interfaces within the bridge.

.. code-block::  bash

  # ovs-vsctl list-ifaces br0 tun0
  veth1903c0e4
  veth2daf2599
  veth6afcc070
  veth77b9379f
  veth9406531e
  veth97389395
  vxlan0

Logically, the networking configuration on an OpenShift node looks like
the graphic below.

.. figure:: images/ops/ocp_networking_node.png
   :alt:

Summary
''''''''

When networking isn't working as you expect, and you've already ruled
out DNS (for the 5th time), keep this architecture in mind as you are
troubleshooting your cluster. There's no magic invovled; only
technologies that have proven themselves for years in production.
