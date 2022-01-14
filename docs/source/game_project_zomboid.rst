Project Zomboid
===============

Instructions to deploy a Project Zomboid server.

Install Project Zomboid
-----------------------

From the project root directory, ``cd`` into ``deployment/games/project-zomboid``:

.. code-block:: bash

    cd deployment/games/project-zomboid

Create Steamcmd script:

.. code-block:: bash

    cp -v configs/project_zomboid_update.txt{.example,}

Allow the script to be mounted into container:

.. code-block:: bash

    chcon -v -t container_file_t ./configs/project_zomboid_update.txt

Ensure the script is readable by others because the user in ``steamcmd`` container is not a ``root`` user:

.. code-block:: bash

    chmod og+r configs/project_zomboid_update.txt

Load SELinux security policy:

.. code-block:: bash

    sudo semodule -i selinux/project_zomboid_pod.cil /usr/share/udica/templates/{base_container.cil,net_container.cil}

Install Project Zomboid:

.. code-block:: bash

    podman volume create steam-project-zomboid-server
    podman run -it --rm -v steam-project-zomboid-server:/home/steam/project-zomboid-server:rw -v ./configs/project_zomboid_update.txt:/tmp/project_zomboid_update.txt:ro --security-opt label=type:project_zomboid_pod.process localhost/extra2000/cm2network/steamcmd:TAG bash
    ./steamcmd.sh +runscript /tmp/project_zomboid_update.txt

.. note::

    You need to replace ``TAG`` with tag matched your ``steamcmd`` image tag.

Create configmap file:

.. code-block:: bash

    cp -v configmaps/project-zomboid.yaml{.example,}

Create pod file:

.. code-block:: bash

    cp -v project-zomboid-pod.yaml{.example,}

.. note::

    In ``project-zomboid-pod.yaml`` file, you need to replace ``STEAMCMD_TAG`` with tag matched your ``steamcmd`` image tag.

Configure Project Zomboid
-------------------------

Create volume for Project Zomboid database:

.. code-block:: bash

    podman volume create steam-project-zomboid-database

Spawn a ``steamcmd`` container:

.. code-block:: bash

    podman run -it --rm --memory 3600Mi -v steam-project-zomboid-server:/home/steam/project-zomboid-server:rw -v steam-project-zomboid-database:/home/steam/Zomboid:rw --security-opt label=type:project_zomboid_pod.process localhost/extra2000/cm2network/steamcmd:TAG bash

Create admin password for server ``my-test-server`` and then terminate Project Zomboid after the server idle:

.. code-block:: bash

    cd /home/steam/project-zomboid-server/
    ./start-server.sh -servername my-test-server

.. note::

    You can change ``my-test-server`` to your preferred servername, but you also need to change it in ``project-zomboid-pod.yaml`` file.

Configure memory by setting ``-Xms3590m`` and ``-Xmx3590m`` values in ``/home/steam/project-zomboid-server/ProjectZomboid64.json`` using ``nano``.

To configure sandbox, edit ``/home/steam/Zomboid/Server/my-test-server.ini`` file.

Deploy Project Zomboid
----------------------

Deploy Project Zomboid server:

.. code-block:: bash

    podman play kube --configmap configmaps/project-zomboid.yaml --seccomp-profile-root ./seccomp project-zomboid-pod.yaml

Create systemd files to run at startup:

.. code-block:: bash

    mkdir -pv ~/.config/systemd/user
    cd ~/.config/systemd/user
    podman generate systemd --files --name project-zomboid-pod
    systemctl --user enable pod-project-zomboid-pod.service container-project-zomboid-pod-srv01.service

Configure Firewalld
-------------------

The following ports needed to be opened:

    * ``8766/udp``
    * ``16261/udp``

You can either use ``firewall-cmd`` commands or create zone file ``/etc/firewalld/zones/project-zomboid.xml`` with the following lines:

.. code-block:: xml

    <?xml version="1.0" encoding="utf-8"?>
    <zone>
      <short>project-zomboid</short>
      <description>Zone for Project Zomboid server deployment.</description>
      <port port="22" protocol="tcp"/>
      <port port="8766" protocol="udp"/>
      <port port="16261" protocol="udp"/>
    </zone>
