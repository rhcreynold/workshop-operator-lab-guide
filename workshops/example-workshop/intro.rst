.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>
.. _docs admin: jduncan@redhat.com

=============
Introduction
=============

Important links
----------------
- `RestructuredText in Sphinx Getting started <http://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html>`__
- `Workshop Operator Source <https://github.com/jduncan-rva/workshop-operator>`__

Default Variables
------------------

You can define more variables to fit your specific workshop in ``conf.py`` in the `rst_prolog <http://www.sphinx-doc.org/en/master/usage/configuration.html#confval-rst_prolog>`__ section. 

======================  ==============
Environment Variable    Default Value
======================  ==============
WORKSHOP_NAME           |workshop_name|
STUDENT_NAME            |student_name|
BASTION_HOST            |bastion_host|
MASTER_URL              |master_url|
APP_DOMAIN              |app_domain|
======================  ==============
