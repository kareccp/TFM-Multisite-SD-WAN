#!/bin/bash
set -e

cd ~/shared/rdsv-final

export SDWNS=rdsv
export NSID1=1
export NSID2=2

echo "## Verificando posible problema Calico/Multus"
./check_k8s_network.sh || true

echo "## Limpiando posible escenario VNX previo"
sudo vnx -f vnx/sdedge_nfv.xml --destroy 2>/dev/null || true

echo "## Levantando escenario VNX base"
sudo vnx -f vnx/sdedge_nfv.xml -t

echo "## Levantando sede 1"
./sdedge1.sh

echo "## Esperando pods sede 1"
microk8s kubectl wait --for=condition=Ready pod -n $SDWNS -l app.kubernetes.io/instance=access1 --timeout=300s
microk8s kubectl wait --for=condition=Ready pod -n $SDWNS -l app.kubernetes.io/instance=cpe1 --timeout=300s
microk8s kubectl wait --for=condition=Ready pod -n $SDWNS -l app.kubernetes.io/instance=wan1 --timeout=300s

echo "## Configurando OSPF r1"
./config_ospf_r1.sh

echo "## Levantando SD-WAN sede 1"
./sdwan1.sh

echo "## Levantando sede 2"
./sdedge2.sh

echo "## Esperando pods sede 2"
microk8s kubectl wait --for=condition=Ready pod -n $SDWNS -l app.kubernetes.io/instance=access2 --timeout=300s
microk8s kubectl wait --for=condition=Ready pod -n $SDWNS -l app.kubernetes.io/instance=cpe2 --timeout=300s
microk8s kubectl wait --for=condition=Ready pod -n $SDWNS -l app.kubernetes.io/instance=wan2 --timeout=300s

echo "## Configurando OSPF r2"
./config_ospf_r2.sh

echo "## Levantando SD-WAN sede 2"
./sdwan2.sh

#echo "## Abriendo consolas sede 1 y sede 2"
#bin/sdw-knf-consoles open 1
#bin/sdw-knf-consoles open 2


echo "## Esperando estabilización general"

sleep 30

echo "## Escenario completo de dos sedes levantado."
echo "## Ejecuta ./validate_full_sedes.sh para comprobar OSPF, flujos, rutas y conectividad."


