#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export SDWNS=rdsv
export NSID1=1

echo "## Limpiando posible escenario VNX previo"
sudo vnx -f vnx/sdedge_nfv.xml --destroy 2>/dev/null || true

echo "## Levantando escenario VNX base"
sudo vnx -f vnx/sdedge_nfv.xml -t

echo "## Verificando posible problema Calico/Multus"
./check_k8s_network.sh

#echo "## Abriendo consola VNX"
#sudo vnx -f vnx/sdedge_nfv.xml --console

echo "## Levantando SD-Edge sede 1"
./sdedge1.sh

echo "## Esperando pods Running"
microk8s kubectl wait --for=condition=Ready pod -n $SDWNS -l app.kubernetes.io/instance=access1 --timeout=300s
microk8s kubectl wait --for=condition=Ready pod -n $SDWNS -l app.kubernetes.io/instance=cpe1 --timeout=300s
microk8s kubectl wait --for=condition=Ready pod -n $SDWNS -l app.kubernetes.io/instance=wan1 --timeout=300s

echo "## Configurando OSPF en router r1"

sudo lxc-attach -n r1 -- bash -c "sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons"

sudo lxc-attach -n r1 -- service frr restart

sudo lxc-attach -n r1 -- vtysh \
-c "conf t" \
-c "interface eth3" \
-c "ip ospf mtu-ignore" \
-c "exit" \
-c "router ospf" \
-c "network 192.168.255.0/24 area 0" \
-c "network 10.20.1.0/24 area 0" \
-c "network 10.20.0.0/24 area 0" \
-c "passive-interface eth1" \
-c "passive-interface eth2" \
-c "no passive-interface eth3" \
-c "end" \
-c "write memory"

echo "## Esperando vecindad OSPF r1-CPE"
sleep 15

echo "## Levantando SD-WAN sede 1"
./sdwan1.sh

echo "## Esperando estabilización"
sleep 10

echo "## Abriendo consolas sede 1"
bin/sdw-knf-consoles open 1

echo "## Validación rápida"
microk8s kubectl get pods -n $SDWNS -o wide

echo "## Imagen CPE"
microk8s kubectl describe pod -n $SDWNS $(microk8s kubectl get pod -n $SDWNS -l app.kubernetes.io/instance=cpe1 -o jsonpath='{.items[0].metadata.name}') | grep Image

echo "## Imagen WAN"
microk8s kubectl describe pod -n $SDWNS $(microk8s kubectl get pod -n $SDWNS -l app.kubernetes.io/instance=wan1 -o jsonpath='{.items[0].metadata.name}') | grep Image

echo "## OSPF"
microk8s kubectl exec -n $SDWNS deploy/cpe1-cpechart -- vtysh -c "show ip ospf neighbor"

echo "## OVS WAN"
microk8s kubectl exec -n $SDWNS deploy/wan1-wanchart -- ovs-vsctl show

echo "## Flujos OpenFlow"
microk8s kubectl exec -n $SDWNS deploy/wan1-wanchart -- ovs-ofctl -O OpenFlow13 dump-flows brwan

echo "## Escenario sede 1 levantado correctamente"