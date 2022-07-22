Installation
============

Download from Github
-------------------------------------------------------

First, you'll need to obtain a copy of `Hive-in-a-box`_ 's code from Github

.. code-block:: bash
    
    git clone https://github.com/Someguy123/hive-docker.git
    cd hive-docker


Install Docker
--------------

If you don't already have `Docker`_ installed on your system, Hive-in-a-box includes the **install_docker** command,
which will automatically install Docker for you.

.. code-block:: bash
    
    ./run.sh install_docker


Obtaining a Hive Docker Image
-----------------------------


(1) Install a Hive Docker Image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. Important::
    
    It's strongly recommended to use the `Binary Hive Docker Images by Someguy123`_ rather than trying to build
    Hive from source, as this ensures compatibility with any snapshots, or special configurations designed for
    use with Someguy123's docker images.

To install the latest **Low Memory Mode Docker Image for Hive**, simply use the ``install`` command,
which will install the latest stable image for seeds / witness nodes.

.. code-block:: bash
    
    ./run.sh install

(2) Build a Hive Docker Image from source
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you don't trust Someguy123's binary images, or you need to build a custom branch / use special build flags,
then you can build an image using the ``build`` command.

**Usage:** ``./run.sh build [version] [tag tag_name] [build_args]``

For example, to build the branch ``master`` with the build arguments ``SKIP_BY_TX_ID=ON`` and ``ENABLE_MIRA=ON`` ,
into the docker tag ``customhive:master`` , you would run the following:

.. code-block:: bash

    ./run.sh build master tag 'customhive:master' 'SKIP_BY_TX_ID=ON' 'ENABLE_MIRA=ON'


Sync / Replay / Download Chain State
------------------------------------

There are several ways to get your node from zero, to fully synced, ranked here from slowest to fastest.

  * **Syncing up from scratch** (no blockchain, index, or shared memory file) (**SLOWEST**)
  * **Blockchain Replay** - Downloading just the ``block_log`` and replaying the blockchain (**FASTER, BUT STILL SLOW**)
  * **State Snapshot** - (Hive-specific) Downloading ``block_log``, ``block_log.index`` and a state snapshot folder (**PRETTY FAST**)
  * **Full Chainstate Dump** - Downloading ``block_log``, ``block_log.index``, and a ``shared_memory.bin`` file taken from a pre-replayed node (**FASTEST**)

Each method has it's own advantages and disadvantages, along with varying speeds.

We're going to show them in order of fastest to slowest below. You should choose ONE of the below options to
get set up.


Full Chainstate Dump
^^^^^^^^^^^^^^^^^^^^

Restoring from a full chainstate dump requires you to have the following 3 files:

  * ``block_log`` - The full blockchain, as a file. As of November 2020, this file is currently **294 GIGABYTES**
  * ``block_log.index`` - The blockchain index, not to be confused with the state file(s) (``shared_memory.bin`` or ``rocksdb``)
  * ``shared_memory.bin`` - A node state file, essentially a RAM dump of the node, containing various binary data related to the
    synchronisation status, the plugins that are enabled, and other state data. (currently **17 GIGABYTES** for standard seed/witness nodes)

All three of these files are available from `Privex's File Server`_ via Rsync and HTTP(S).

**The downside of a chainstate dump**:

    A raw ``shared_memory.bin`` file is strongly tied to a specific version of Hive, a specific binary ``hived`` executable, along with
    plugin configuration. Generally, the ones on `Privex's File Server`_ are taken from a system which is using the 
    default `Hive-in-a-box`_ configuration, with whatever the latest Hive version is.

    They're also linked to a specific block_log length and block_log.index, however, ``fix-blocks`` automatically handles block_log size
    synchronisation through truncation or appending to the block_log, along with replacing the index file to match.


The easiest way to download them, is by using the :ref:`Fix Blocks` feature, which will ask you which parts of the chain state
that you'd like to download.

.. code-block:: bash
    
    ./run.sh fix-blocks


Simply hit ``y`` to the block_log, index, and shared_memory questions, and then start your node up:


.. code-block:: bash
    
    ./run.sh start


State Snapshot
^^^^^^^^^^^^^^

As of Hive v1.24.0 (HF24), a new feature has been added, known as **state snapshots**, which are a folder containing the chain state from memory,
in a smaller, somewhat more portable RocksDB-driven database format.

Unlike chainstate dumps, state snapshots are a lot more forgiving, they don't need you to have the same length block_log, the same plugins, or
even the exact same Hive version.

For comparison - a standard ``shared_memory.bin`` file is currently 17GB (but can be bigger to download due to the fact it's a sparse file - filled with zeros),
while a standard state snapshot is only 3GB.

The easiest way to download a state snapshot, is by using the :ref:`Fix Blocks` feature, which will ask you which parts of the chain state
that you'd like to download.

.. code-block:: bash
    
    ./run.sh fix-blocks


Simply hit ``y`` to the block_log, index, and state snapshot questions, and then start your node with ``loadsnap privexsnap`` to
start importing the downloaded snapshot.

.. code-block:: bash

    ./run.sh loadsnap privexsnap

Blockchain Replay
^^^^^^^^^^^^^^^^^

Lorem ipsum dolor


Syncing up from scratch
^^^^^^^^^^^^^^^^^^^^^^^

Lorem ipsum dolor




.. _Privex's File Server: http://files.privex.io
.. _Hive-in-a-box: https://github.com/Someguy123/hive-docker
.. _Docker: https://www.docker.com
.. _Github Project: https://github.com/Someguy123/hive-docker
.. _Binary Hive Docker Images by Someguy123: https://hub.docker.com/repository/docker/someguy123/hive

