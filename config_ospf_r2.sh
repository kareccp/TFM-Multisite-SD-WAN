#!/bin/bash
set -e

echo "## Configurando OSPF en router r2"

sudo lxc-attach -n r2 -- bash -c "sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons"

sudo lxc-attach -n r2 -- service frr restart

sudo lxc-attach -n r2 -- vtysh \
-c "conf t" \
-c "interface eth3" \
-c "ip ospf mtu-ignore" \
-c "exit" \
-c "router ospf" \
-c "network 192.168.255.0/24 area 0" \
-c "network 10.20.2.0/24 area 0" \
-c "network 10.20.0.0/24 area 0" \
-c "passive-interface eth1" \
-c "passive-interface eth2" \
-c "no passive-interface eth3" \
-c "end" \
-c "write memory"

echo "## Esperando vecindad OSPF r2-CPE2"
sleep 15

sudo lxc-attach -n r2 -- vtysh -c "show ip ospf neighbor"