Project Zomboid
===============

Instructions to deploy a Project Zomboid server.

Install Project Zomboid
-----------------------

From the project root directory, ``cd`` into ``deployment/games/project-zomboid``:

.. code-block:: bash
    :linenos:

    cd deployment/games/project-zomboid

Create Steamcmd script:

.. code-block:: bash
    :linenos:

    cp -v configs/project_zomboid_update.txt{.example,}

Allow the script to be mounted into container:

.. code-block:: bash
    :linenos:

    chcon -v -t container_file_t ./configs/project_zomboid_update.txt

Ensure the script is readable by others because the user in ``steamcmd`` container is not a ``root`` user:

.. code-block:: bash
    :linenos:

    chmod og+r configs/project_zomboid_update.txt

Load SELinux security policy:

.. code-block:: bash
    :linenos:

    sudo semodule \
    -i selinux/project_zomboid_podman.cil \
    /usr/share/udica/templates/{base_container.cil,net_container.cil}

Create Project Zomboid volume:

.. code-block:: bash
    :linenos:

    podman volume create steam-project-zomboid-server

Spawn ``steamcmd`` container:

.. code-block:: bash
    :linenos:

    podman run -it --rm \
    -v steam-project-zomboid-server:/home/steam/project-zomboid-server:rw \
    -v ./configs/project_zomboid_update.txt:/tmp/project_zomboid_update.txt:ro \
    --security-opt label=type:project_zomboid_podman.process \
    localhost/extra2000/cm2network/steamcmd \
    bash

Install Project Zomboid:

.. code-block:: bash
    :linenos:

    ./steamcmd.sh +runscript /tmp/project_zomboid_update.txt

Exit the container:

.. code-block:: bash
    :linenos:

    exit

Create configmap file:

.. code-block:: bash
    :linenos:

    cp -v configmaps/project-zomboid.yaml{.example,}

Create pod file:

.. code-block:: bash
    :linenos:

    cp -v project-zomboid-pod.yaml{.example,}

Configure Project Zomboid
-------------------------

Create volume for Project Zomboid database:

.. code-block:: bash
    :linenos:

    podman volume create steam-project-zomboid-database

Spawn a ``steamcmd`` container:

.. code-block:: bash
    :linenos:

    podman run -it --rm \
    --memory 3600M \
    -v steam-project-zomboid-server:/home/steam/project-zomboid-server:rw \
    -v steam-project-zomboid-database:/home/steam/Zomboid:rw \
    --security-opt label=type:project_zomboid_podman.process \
    localhost/extra2000/cm2network/steamcmd \
    bash

Create admin password for server ``my-test-server`` and then terminate Project Zomboid after the server idle:

.. code-block:: bash
    :linenos:

    cd /home/steam/project-zomboid-server/
    ./start-server.sh -servername my-test-server

.. note::

    You can change ``my-test-server`` to your preferred servername, but you also need to change it in ``project-zomboid-pod.yaml`` file.

Configure memory by setting ``-Xms3590m`` and ``-Xmx3590m`` values in ``/home/steam/project-zomboid-server/ProjectZomboid64.json`` using ``nano``.

To soft reset the server, add ``-Dsoftreset`` parameter into ``/home/steam/project-zomboid-server/ProjectZomboid64.json``. The server will be automatically terminated and then remove the parameter.

To configure sandbox, edit ``/home/steam/Zomboid/Server/my-test-server.ini`` file.

Deploy Project Zomboid
----------------------

Deploy Project Zomboid server:

.. code-block:: bash
    :linenos:

    podman play kube \
    --configmap configmaps/project-zomboid.yaml \
    --seccomp-profile-root ./seccomp \
    project-zomboid-pod.yaml

Configure Firewalld
-------------------

The following ports needed to be opened:

    * ``8766/udp``
    * ``16261/udp``
    * ``16262/udp``

You can either use ``firewall-cmd`` commands or create zone file ``/etc/firewalld/zones/project-zomboid.xml`` with the following lines:

.. code-block:: xml

    <?xml version="1.0" encoding="utf-8"?>
    <zone>
      <short>project-zomboid</short>
      <description>Zone for Project Zomboid server deployment.</description>
      <port port="22" protocol="tcp"/>
      <port port="8766" protocol="udp"/>
      <port port="16261" protocol="udp"/>
      <port port="16262" protocol="udp"/>
    </zone>

.. note::

    Port 22 is for your SSH and it is not used by the game.

Autostart On Boot
-----------------

Instructions how to autostart Project Zomboid Podman Pod on boot.

Create user's systemd services directory if not exists:

.. code-block:: bash
    :linenos:

    mkdir -pv ~/.config/systemd/user/

Create a oneshot systemd service file ``~/.config/systemd/user/project-zomboid-pod.service`` with the following content:

.. code-block:: cfg
    :linenos:

    [Unit]
    Description=Autostart Project Zomboid Podman Pod on boot
    Wants=network-online.target
    After=network-online.target

    [Service]
    ExecStart=/usr/bin/podman pod start project-zomboid-pod
    Type=oneshot
    RemainAfterExit=yes

    [Install]
    WantedBy=default.target
