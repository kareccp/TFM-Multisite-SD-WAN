#!/bin/bash
set +e

export KUBECTL="microk8s kubectl"

echo "## Reiniciando componentes de red Kubernetes: Calico / Multus"

echo "## Estado inicial"
$KUBECTL get pods -n kube-system | grep -E "calico|multus"

echo "## Reiniciando calico-node"
$KUBECTL delete pod -n kube-system -l k8s-app=calico-node 2>/dev/null

echo "## Reiniciando calico-kube-controllers"
$KUBECTL delete pod -n kube-system -l k8s-app=calico-kube-controllers 2>/dev/null

echo "## Reiniciando multus"
$KUBECTL delete pod -n kube-system -l app=multus 2>/dev/null

echo "## Esperando recuperación de Calico/Multus"
sleep 60

echo "## Estado final"
$KUBECTL get pods -n kube-system | grep -E "calico|multus"

echo "## Limpieza de pods rdsv atascados"
$KUBECTL delete pod -n rdsv --all --force --grace-period=0 2>/dev/null

echo "## Esperando nueva creación de pods"
sleep 30

echo "## Pods rdsv"
$KUBECTL get pods -n rdsv -o wide

