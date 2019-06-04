Lab 7 - Routing layer
=======================

.. important::

  For this lab, SSH to your master node and escalate to your root user so you can interact with OpenShift via the ``oc`` command line client.

The routing layer integrated with OpenShift uses HAProxy by default. It maps the publicly available route you assign an
application and maps it back to the corresponding pods in your cluster.
Each time an application or route is updated (created, retired, scaled
up or down), the configuration in HAProxy is updated by OpenShift.
HAProxy runs in a pod in the default project on your infrastructure
node.

.. note:: Other routing options

  OpenShift uses a plugin framework for its routing layer. The default router for OpenShift 3.11 is HAProxy, but OpenShift also ships with an F5 router plugin. Additionally, there are cloud-provider specific and third-party router plugins.

  OpenShift 4 transitioned to `nginx <https://www.nginx.com/>`__ as the default router.

Inspecting HAProxy in OpenShift
'''''''''''''''''''''''''''''''''

::

  # oc project default
  # oc get pods
  NAME                       READY     STATUS    RESTARTS   AGE
  docker-registry-1-77rmv    1/1       Running   0          2d
  registry-console-1-n7kbk   1/1       Running   0          2d
  router-1-mwb89             1/1       Running   0          2d <--- router pod running HAProxy

If you know the name of a pod, you can us ``oc rsh`` to connect to it
remotely. This is doing some fun magic using ``ssh`` and ``nsenter``
under the covers to provide a connection to the proper node inside the
proper namespaces for the pod. Looking in the ``haproxy.config`` file
for references to ``app-cli`` gives displays your router configuration
for that application. ``Ctrl-D`` will exit out of your ``rsh`` session.

::

  # oc rsh router-1-mwb89
  sh-4.2$ grep app-cli haproxy.config
  backend be_http:image-uploader:app-cli
  server pod:app-cli-1-tthhf:app-cli:10.130.0.36:8080 10.130.0.36:8080 cookie 91b8f12aa1ca5b82e34e730715b58254 weight 256 check inter 5000ms
  server pod:app-cli-1-bgt75:app-cli:10.130.0.41:8080 10.130.0.41:8080 cookie 0f411f181edfdfb13c0c0d1b562f5efd weight 256 check inter 5000ms
  server pod:app-cli-1-26fgz:app-cli:10.131.0.6:8080 10.131.0.6:8080 cookie 67b4bd5bb54b037c5b37c8acadcfe833 weight 256 check inter 5000ms

If you use the ``oc get pods`` command for the Image Uploader project
and limit its output for the app-cli application, you can see the IP
addresses in HAProxy match the pods for the application.

::

  # oc get pods -l app=app-cli -n image-uploader -o wide
  NAME              READY     STATUS    RESTARTS   AGE       IP            NODE
  app-cli-1-26fgz   1/1       Running   0          3h        10.131.0.6    ip-172-16-50-98.ec2.internal
  app-cli-1-bgt75   1/1       Running   0          3h        10.130.0.41   ip-172-16-245-111.ec2.internal
  app-cli-1-tthhf   1/1       Running   0          3h        10.130.0.36   ip-172-16-245-111.ec2.internal

To confirm HAProxy is automatically updated, let's scale ``app-cli``
back down to 1 pod and re-check the router configuration.

::

  # oc scale dc/app-cli -n image-uploader --replicas=1
  deploymentconfig.apps.openshift.io "app-cli" scaled

  oc get pods -l app=app-cli -n image-uploader -o wide

  NAME READY STATUS RESTARTS AGE IP NODE app-cli-1-tthhf 1/1 Running 0 3h
  10.130.0.36 ip-172-16-245-111.ec2.internal

Instead of having to connect to a shell session inside the router pod, you can use ``oc exec`` to run a single command in a pod and get the output.

::

  oc exec router-1-mwb89 grep app-cli haproxy.config

  backend be\_http:image-uploader:app-cli server
  pod:app-cli-1-tthhf:app-cli:10.130.0.36:8080 10.130.0.36:8080 cookie
  91b8f12aa1ca5b82e34e730715b58254 weight 256 check inter 5000ms \`\`\`

  We were able to confirm that our HAProxy configuration updates
  automatically when applications are updated.

Summary
'''''''''''''

We know this is a mountain of content. Our goal is to present you with
information that will be helpful as you sink your teeth into your own
OpenShift clusters in your own infrastructure. These are some of the
fundamental tools and tricks that are going to be helpful as you begin
this journey.
