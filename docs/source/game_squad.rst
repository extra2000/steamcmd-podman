Squad
=====

Instructions to deploy a Squad server.

Install Squad
-------------

From the project root directory, ``cd`` into ``deployment/games/squad``:

.. code-block:: bash
    :linenos:

    cd deployment/games/squad

Create Steamcmd script:

.. code-block:: bash
    :linenos:

    cp -v configs/squad_update.txt{.example,}

Allow the script to be mounted into container:

.. code-block:: bash
    :linenos:

    chcon -v -t container_file_t ./configs/squad_update.txt

Load SELinux security policy:

.. code-block:: bash
    :linenos:

    sudo semodule \
    -i selinux/squad_podman.cil \
    /usr/share/udica/templates/{base_container.cil,net_container.cil}

Create Squad volume:

.. code-block:: bash
    :linenos:

    podman volume create steam-squad-server

Spawn a ``steamcmd`` container:

.. code-block:: bash
    :linenos:

    podman run -it --rm \
    -v steam-squad-server:/home/steam/squad-server:rw \
    -v ./configs/squad_update.txt:/tmp/squad_update.txt:ro \
    --security-opt label=type:squad_podman.process \
    localhost/extra2000/cm2network/steamcmd \
    bash

Install Squad:

.. code-block:: bash
    :linenos:

    ./steamcmd.sh +runscript /tmp/squad_update.txt

Exit the container:

.. code-block:: bash
    :linenos:

    exit

Create configmap file:

.. code-block:: bash
    :linenos:

    cp -v configmaps/squad.yaml{.example,}

Create pod file:

.. code-block:: bash
    :linenos:

    cp -v squad-pod.yaml{.example,}

Deploy Squad server:

.. code-block:: bash
    :linenos:

    podman play kube \
    --configmap configmaps/squad.yaml \
    --seccomp-profile-root ./seccomp \
    squad-pod.yaml

Configure Firewalld
-------------------

The following ports needed to be opened:

    * ``7787/tcp``
    * ``7788/tcp``
    * ``27165/tcp``
    * ``27166/tcp``
    * ``21114/tcp``
    * ``7787/udp``
    * ``7788/udp``
    * ``27165/udp``
    * ``27166/udp``
    * ``21114/udp``

You can either use ``firewall-cmd`` commands or create zone file ``/etc/firewalld/zones/squad.xml`` with the following lines:

.. code-block:: xml

    <?xml version="1.0" encoding="utf-8"?>
    <zone>
      <short>squad</short>
      <description>Zone for Squad server deployment.</description>
      <port port="22" protocol="tcp"/>
      <port port="7787" protocol="tcp"/>
      <port port="7788" protocol="tcp"/>
      <port port="27165" protocol="tcp"/>
      <port port="27166" protocol="tcp"/>
      <port port="21114" protocol="tcp"/>
      <port port="7787" protocol="udp"/>
      <port port="7788" protocol="udp"/>
      <port port="27165" protocol="udp"/>
      <port port="27166" protocol="udp"/>
      <port port="21114" protocol="udp"/>
    </zone>

.. note::

    Port 22 is for your SSH and it is not used by the game.

Autostart On Boot
-----------------

Instructions how to autostart Squad Podman Pod on boot.

Create user's systemd services directory if not exists:

.. code-block:: bash
    :linenos:

    mkdir -pv ~/.config/systemd/user/

Create a oneshot systemd service file ``~/.config/systemd/user/squad-pod.service`` with the following content:

.. code-block:: cfg
    :linenos:

    [Unit]
    Description=Autostart Squad Podman Pod on boot
    Wants=network-online.target
    After=network-online.target

    [Service]
    ExecStart=/usr/bin/podman pod start squad-pod
    Type=oneshot
    RemainAfterExit=yes

    [Install]
    WantedBy=default.target
