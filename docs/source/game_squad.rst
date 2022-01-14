Squad
=====

Instructions to deploy a Squad server.

Install Squad
-------------

From the project root directory, ``cd`` into ``deployment/games/squad``:

.. code-block:: bash

    cd deployment/games/squad

Create Steamcmd script:

.. code-block:: bash

    cp -v configs/squad_update.txt{.example,}

Allow the script to be mounted into container:

.. code-block:: bash

    chcon -v -t container_file_t ./configs/squad_update.txt

Load SELinux security policy:

.. code-block:: bash

    sudo semodule -i selinux/squad_pod.cil /usr/share/udica/templates/{base_container.cil,net_container.cil}

Install Squad:

.. code-block:: bash

    podman volume create steam-squad-server
    podman run -it --rm -v steam-squad-server:/home/steam/squad-server:rw -v ./configs/squad_update.txt:/tmp/squad_update.txt:ro --security-opt label=type:squad_pod.process localhost/extra2000/cm2network/steamcmd:TAG bash
    ./steamcmd.sh +runscript /tmp/squad_update.txt

.. note::

    You need to replace ``TAG`` with tag matched your ``steamcmd`` image tag.

Create configmap file:

.. code-block:: bash

    cp -v configmaps/squad.yaml{.example,}

Create pod file:

.. code-block:: bash

    cp -v squad-pod.yaml{.example,}

.. note::

    In ``squad-pod.yaml`` file, you need to replace ``STEAMCMD_TAG`` with tag matched your ``steamcmd`` image tag.

Deploy Squad server:

.. code-block:: bash

    podman play kube --configmap configmaps/squad.yaml --seccomp-profile-root ./seccomp squad-pod.yaml

Create systemd files to run at startup:

.. code-block:: bash

    mkdir -pv ~/.config/systemd/user
    cd ~/.config/systemd/user
    podman generate systemd --files --name squad-pod
    systemctl --user enable pod-squad-pod.service container-squad-pod-srv01.service

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
