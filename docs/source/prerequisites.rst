Prerequisites
=============

Example how to deploy setup prerequisites before deploying game servers.

Clone repository
----------------

Execute the following command to clone ``steamcmd-podman`` repository:

.. code-block:: bash
    :linenos:

    mkdir ~/extra2000
    cd ~/extra2000
    git clone --recursive https://github.com/extra2000/steamcmd-podman.git

Then, ``cd`` into project root directory:

.. code-block:: bash
    :linenos:

    cd steamcmd-podman

Clone ``steamcmd`` repository into ``./src/``:

.. code-block:: bash
    :linenos:

    git clone https://github.com/CM2Walki/steamcmd.git src/steamcmd

Build Steamcmd image
--------------------

From the project root directory, ``cd`` into ``src/steamcmd/buster`` and then execute the following command:

.. code-block:: bash
    :linenos:

    cd src/steamcmd/bullseye
    podman build -t extra2000/cm2network/steamcmd -f Dockerfile .
