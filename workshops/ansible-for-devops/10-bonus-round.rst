.. sectionauthor:: Chris Reynolds <creynold@redhat.com>
.. _docs admin: creynold@redhat.com

==================================================
Bonus Round
==================================================

In this lab you will NOT be guided, but given tasks that need to be implemented.

Setting the NTP
---------------

Find a role on Ansible Galaxy that sets ntp to ``time.google.com``

Load this into Ansible Tower and successfully run the playbook.

Remove Nano
-----------

Your security team has indicated that Nano is a threat and is to no longer be installed.

Either create a playbook or find a role on Ansible Galaxy that removes Nano from all nodes.

Load this into Ansible Tower and successfully run the playbook.

Update the Webpage
-------------------

Update the ``index.html`` from earlier to have the text "Winter is Coming".

Have Ansible Tower deploy this change into both Site-A and Site-B.
