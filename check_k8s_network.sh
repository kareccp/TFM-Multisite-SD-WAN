#!/bin/bash
set +e

export KUBECTL="microk8s kubectl"

echo "## Comprobando red Kubernetes"

BAD_PODS=$($KUBECTL get pods -n rdsv --no-headers 2>/dev/null | grep -E "ContainerCreating|Pending|Unknown|CrashLoopBackOff|Error" | wc -l)

if [ "$BAD_PODS" -gt 0 ]; then
    echo "## Detectados pods atascados en rdsv. Reiniciando Calico/Multus..."

    $KUBECTL delete pod -n kube-system -l k8s-app=calico-node 2>/dev/null
    $KUBECTL delete pod -n kube-system -l k8s-app=calico-kube-controllers 2>/dev/null
    $KUBECTL delete pod -n kube-system -l app=multus 2>/dev/null

    sleep 60

    echo "## Borrando pods rdsv atascados"
    $KUBECTL delete pod -n rdsv --all --force --grace-period=0 2>/dev/null

    sleep 60
else
    echo "## No se detectan pods rdsv atascados"
fi

echo "## Estado Calico/Multus"
$KUBECTL get pods -n kube-system | grep -E "calico|multus"

echo "## Estado rdsv"
$KUBECTL get pods -n rdsv -o wide 2>/dev/null
