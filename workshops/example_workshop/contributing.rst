.. sectionauthor:: Jamie Duncan <jduncan@redhat.com>
.. _docs admin: jduncan@redhat.com

=============
Contributing
=============

Most of our workshops take very basic environments and wrap them around a lab guide to provide a good learning experience for our customers. The typical contribution to this project will be to create a new lab guide, or port over an existing one. For more complex workshops, you may need to extend or modify the actual `Workshop Operator <https://github.com/jduncan-rva/workshop-operator>`__. Contributions to the workshop operator are covered in its documentation, and out of scope for this document.

Documentation Format
---------------------

This lab guide engine uses `Sphinx <http://www.sphinx-doc.org/en/master/>__ to render the HTML that's presented to each user. The default documentation format we use is `RestructuredText <http://docutils.sourceforge.net/rst.html>`__.

.. admonition:: What about MarkDown?

  If you choose, you can also use MarkDown (`CommonMark format <https://commonmark.org/>`__ to render your lab guides. Just make sure your files are saved with a ``.md`` file extension and go for it! Your initial page should be named ``index.md``, and then follow the same conventions as this example_workshop.

Adding a workshop
------------------

To contribute a new workshop, we follow the standard fork and branch methodology of git.

Fork the repository
````````````````````

To add an new workshop, begin by forking :github_url:`Github project<workshop-operator-lab-guide>`.

.. code-block:: bash

  $ git clone git@github.com:jduncan-rva/workshop-operator-lab-guide.git

Create your new workshop directory
```````````````````````````````````

After changing to that direction, create a new directory in ``./workshops``.

.. code-block:: bash

    $ mkdir -p ./workshops/my_workshop
    $ ll workshops/
  total 0
  drwxr-xr-x   5 jduncan  wheel  160 Apr  3 15:40 .
  drwxr-xr-x  11 jduncan  wheel  352 Apr  3 15:40 ..
  drwxr-xr-x   7 jduncan  wheel  224 Apr  2 10:25 dcmetromap
  drwxr-xr-x  10 jduncan  wheel  320 Apr  3 10:06 example_workshop
  drwxr-xr-x   2 jduncan  wheel   64 Apr  3 15:40 my_workshop

Add your project to the CI/CD Workflow
```````````````````````````````````````

We have a functional CI/CD workflow in place to build container images for all projects in the lab guide engine. To have yours built, add a new line to ``.travis.yml`` in the ``env`` section. For example:

.. code-block:: yaml

  env:
    - WORKSHOP_NAME=example_workshop
    - WORKSHOP_NAME=dcmetromap
    - WORKSHOP_NAME=new_workshop

Once that is done, open up a Pull Request against :github_url:`Github <workshop-operator-lab-guide>`.
