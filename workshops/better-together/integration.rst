Discussion - OpenShift and Ansible Together
=======================================================

Deploying and managing an OpenShift cluster is controlled by Ansible.
The
`openshift-ansible <https://github.com/openshift/openshift-ansible>`__ project is used to deploy and scale OpenShift clusters, as well as enable new features like `OpenShift Container Storage <https://www.openshift.com/products/container-storage/>`__.

Deploying OpenShift
'''''''''''''''''''''''''

Your entire OpenShift cluster was deployed using Ansible. The inventory
used to deploy your cluster is on your bastion host at the default
inventory location for Ansible, ``/etc/ansible/hosts``. To deploy an
OpenShift cluster on RHEL 7, after registering it and subscribing it to
the proper repositories two Ansible playbooks need to be run:

::

  ansible-playook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
  ansible-playook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml

The deployment process takes 30-40 minutes to complete, depending on the size of your cluster. To save that time, we've got you covered and have already deployed your OpenShift cluster. In fact, all lab environments were provisioned using a single ansible playbook from `another ansible playbook that incorporates the playbooks that deploy OpenShift <https://github.com/jduncan-rva/linklight>`__.

Operations and Lifecycle management
''''''''''''''''''''''''''''''''''''

In additon to deploying OpenShift, Ansible is used to modify your
existing cluster. These playbooks are also located in
``/usr/share/ansible/openshift-ansible/``. They can do things like:

-  Add a node to your cluster
-  Deploy OpenShift Container Storage (OCS)
-  Deploy metrics or log aggregation to an existing cluster
-  Deploy `Cloudforms <https://www.redhat.com/en/technologies/management/cloudforms>`__ in your OpenShift cluster
-  Other operations like re-deploying encryption certificates

Taking a look at the playbook options available from
``openshift-ansible``, you see:

::

  $ ls /usr/share/ansible/openshift-ansible/playbooks/
  adhoc/
  common/
  openshift-autoheal/
  openshift-grafana/
  openshift-master/
  openshift-node/
  openshift-web-console/
  roles/
  aws/
  container-runtime/
  openshift-checks/
  openshift-hosted/
  openshift-metrics/
  openshift-node-problem-detector/
  openstack/
  azure/
  deploy_cluster.yml
  openshift-descheduler
  openshift-loadbalancer
  openshift-monitor-availability
  openshift-prometheus
  prerequisites.yml
  byo/
  gcp/
  openshift-etcd/
  openshift-logging/
  openshift-monitoring/
  openshift-provisioners/
  README.md
  cluster-operator/
  init/
  openshift-glusterfs/
  openshift-management/
  openshift-nfs/
  openshift-service-catalog/
  redeploy-certificates.yml

.. admonition:: Why not do this right now?

  If you want to add something to your cluster, please feel free. Because this process is simply running ``ansible-playbook``, we're not going to ask everyone watch ansible output scroll down their screen for 10 or more minutes.

Summary
'''''''''

We've talked about Ansible fundamentals, an we've discussed OpenShift architecture.

This section has been about the deeper relationship between OpenShift
and Ansible. All major lifecycle events are handled using Ansible.

Next, we'll take a look at an OpenShift deployment that provides
everything you need to create and test a full CI/CD workflow in
OpenShift.
