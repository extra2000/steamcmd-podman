7 Days To Die
=============

Instructions to deploy a 7 Days To Die server.

Install 7 Days To Die
---------------------

From the project root directory, ``cd`` into ``deployment/games/seven-days-to-die``:

.. code-block:: bash
    :linenos:

    cd deployment/games/seven-days-to-die

Create Steamcmd script:

.. code-block:: bash
    :linenos:

    cp -v configs/sevendaystodie_update.txt{.example,}

Allow the script to be mounted into container:

.. code-block:: bash
    :linenos:

    chcon -v -t container_file_t ./configs/sevendaystodie_update.txt

Ensure the script is readable by others because the user in ``steamcmd`` container is not a ``root`` user:

.. code-block:: bash
    :linenos:

    chmod og+r configs/sevendaystodie_update.txt

Load SELinux security policy:

.. code-block:: bash
    :linenos:

    sudo semodule \
    -i selinux/sevendaystodie_podman.cil \
    /usr/share/udica/templates/{base_container.cil,net_container.cil}

Create 7 Days To Die volume:

.. code-block:: bash
    :linenos:

    podman volume create steam-sevendaystodie-server

Spawn ``steamcmd`` container:

.. code-block:: bash
    :linenos:

    podman run -it --rm \
    -v steam-sevendaystodie-server:/home/steam/sevendaystodie-server:rw \
    -v ./configs/sevendaystodie_update.txt:/tmp/sevendaystodie_update.txt:ro \
    --security-opt label=type:sevendaystodie_podman.process \
    localhost/extra2000/cm2network/steamcmd \
    bash

Install 7 Days To Die:

.. code-block:: bash
    :linenos:

    ./steamcmd.sh +runscript /tmp/sevendaystodie_update.txt

Exit the container:

.. code-block:: bash
    :linenos:

    exit

Create configmap file:

.. code-block:: bash
    :linenos:

    cp -v configmaps/sevendaystodie.yaml{.example,}

Create pod file:

.. code-block:: bash
    :linenos:

    cp -v sevendaystodie-pod.yaml{.example,}

Configure 7 Days To Die
-----------------------

Create volume for 7 Days To Die database:

.. code-block:: bash
    :linenos:

    podman volume create steam-sevendaystodie-database

Spawn a ``steamcmd`` container:

.. code-block:: bash
    :linenos:

    podman run -it --rm \
    -v steam-sevendaystodie-server:/home/steam/sevendaystodie-server:rw \
    -v steam-sevendaystodie-database:/home/steam/.local/share/7DaysToDie:rw \
    --security-opt label=type:sevendaystodie_podman.process \
    localhost/extra2000/cm2network/steamcmd \
    bash

Edit settings in ``/home/steam/sevendaystodie-server/serverconfig.xml``.

Deploy 7 Days To Die
--------------------

Deploy 7 Days To Die server:

.. code-block:: bash
    :linenos:

    podman play kube \
    --configmap configmaps/sevendaystodie.yaml \
    --seccomp-profile-root ./seccomp \
    sevendaystodie-pod.yaml

Configure Firewalld
-------------------

The following ports needed to be opened:

    * ``8080/tcp``
    * ``8081/tcp``
    * ``8082/tcp``
    * ``26900/tcp``
    * ``26900/udp``
    * ``26901/udp``
    * ``26902/udp``
    * ``26903/udp``

.. warning::

    * Port ``8080-8081`` are optional and only required if you want to administer your server remotely.
    * Port ``8082`` is optional and it is used by Alloc's mods control panel.

You can either use ``firewall-cmd`` commands or create zone file ``/etc/firewalld/zones/sevendaystodie.xml`` with the following lines:

.. code-block:: xml

    <?xml version="1.0" encoding="utf-8"?>
    <zone>
      <short>sevendaystodie</short>
      <description>Zone for 7 Days To Die server deployment.</description>
      <port port="22" protocol="tcp"/>
      <port port="8080" protocol="tcp"/>
      <port port="8081" protocol="tcp"/>
      <port port="8082" protocol="tcp"/>
      <port port="26900" protocol="tcp"/>
      <port port="26900" protocol="udp"/>
      <port port="26901" protocol="udp"/>
      <port port="26902" protocol="udp"/>
      <port port="26903" protocol="udp"/>
    </zone>

.. note::

    Port 22 is for your SSH and it is not used by the game.

Autostart On Boot
-----------------

Instructions how to autostart 7 Days To Die Podman Pod on boot.

Create user's systemd services directory if not exists:

.. code-block:: bash
    :linenos:

    mkdir -pv ~/.config/systemd/user/

Create a oneshot systemd service file ``~/.config/systemd/user/sevendaystodie-pod.service`` with the following content:

.. code-block:: cfg
    :linenos:

    [Unit]
    Description=Autostart 7 Days To Die Podman Pod on boot
    Wants=network-online.target
    After=network-online.target

    [Service]
    ExecStart=/usr/bin/podman pod start sevendaystodie-pod
    Type=oneshot
    RemainAfterExit=yes

    [Install]
    WantedBy=default.target

Reset World
-----------

To reset the world, do the followings:

Stop the ``sevendaystodie-pod`` pod:

.. code-block:: bash

    podman pod stop sevendaystodie-pod

Execute the following command to remove ``/home/steam/.local/share/7DaysToDie/Saves`` directory:

.. code-block:: bash

    podman run -it --rm \
    -v steam-sevendaystodie-database:/home/steam/.local/share/7DaysToDie:rw \
    localhost/extra2000/cm2network/steamcmd \
    rm -rv /home/steam/.local/share/7DaysToDie/Saves
