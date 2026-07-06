#!/bin/bash
set +e

export KUBECTL="microk8s kubectl"
: ${SDWNS:=rdsv}

echo "## Parando escenario Kubernetes en namespace $SDWNS"

for NETNUM in 1 2
do
  for VNF in access cpe wan
  do
    echo "Uninstall $VNF$NETNUM"
    helm -n $SDWNS uninstall $VNF$NETNUM 2>/dev/null
  done
done

echo "## Esperando borrado normal"
sleep 20

echo "## Forzando pods bloqueados"
$KUBECTL delete pod -n $SDWNS --all --force --grace-period=0 2>/dev/null

echo "## Borrando deployments/replicasets/services huérfanos"
$KUBECTL delete deployments -n $SDWNS --all 2>/dev/null
$KUBECTL delete replicasets -n $SDWNS --all 2>/dev/null
$KUBECTL delete services -n $SDWNS --all 2>/dev/null

echo "## Cerrando ventanas/consolas VNX"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/vnx"
sudo vnx -f sdedge_nfv.xml --destroy

echo "## Estado final"
$KUBECTL get pods -n $SDWNS