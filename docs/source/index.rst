.. _Hive-in-a-box documentation:



Hive-in-a-box Documentation
===========================

.. image:: https://cdn.privex.io/github/hive-docker/hive-in-a-box.png
   :target: https://github.com/Someguy123/hive-docker
   :width: 400px
   :height: 400px
   :alt: Hive-in-a-box Logo
   :align: center

Welcome to the documentation for `Hive-in-a-box`_ - an ongoing project built using the Bash shellscripting language,
designed to make installing, upgrading, monitoring and repairing `Hive`_ and Hive-based blockchain nodes as painless
as possible, while still giving many powerful features for advanced users, and endless customisation via environment
variables.

This documentation is automatically kept up to date by ReadTheDocs, as it is automatically re-built each time
a new commit is pushed to the `Github Project`_ 

.. _Hive-in-a-box: https://github.com/Someguy123/hive-docker
.. _Github Project: https://github.com/Someguy123/hive-docker
.. _Hive: https://hive.io


.. contents::


Quick install
-------------

**Installing from Git**

You can use the :ref:`Fix Blocks` feature to avoid having to **replay** or **sync from scratch**.

.. code-block:: bash

    git clone https://github.com/Someguy123/hive-docker.git
    cd hive-docker
    ./run.sh install
    # Press Y to every option
    ./run.sh fix-blocks
    ./run.sh start





All Documentation
=================

.. toctree::
   :maxdepth: 8
   :caption: Main:

   self
   install


.. toctree::
   :maxdepth: 3
   :caption: Features

   features/index



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
