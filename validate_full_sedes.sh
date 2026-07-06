#!/bin/bash
set +e

cd ~/shared/rdsv-final
export SDWNS=rdsv

echo " VALIDACIÓN ESCENARIO COMPLETO DOS SEDES"

echo ""
echo "## 1. Pods Kubernetes"
microk8s kubectl get pods -n $SDWNS -o wide

echo ""
echo "## 2. Releases Helm"
helm list -n $SDWNS

echo ""
echo "## 3. Imágenes desplegadas"
microk8s kubectl get pods -n $SDWNS -o jsonpath='{range .items[*]}{.metadata.name}{" -> "}{.spec.containers[0].image}{"\n"}{end}'

echo ""
echo "## 4. Estado FRR CPE1"
microk8s kubectl exec -n $SDWNS deploy/cpe1-cpechart -- service frr status

echo ""
echo "## 5. Estado FRR CPE2"
microk8s kubectl exec -n $SDWNS deploy/cpe2-cpechart -- service frr status

echo ""
echo "## 6. OSPF CPE1"
microk8s kubectl exec -n $SDWNS deploy/cpe1-cpechart -- vtysh -c "show ip ospf neighbor"

echo ""
echo "## 7. OSPF CPE2"
microk8s kubectl exec -n $SDWNS deploy/cpe2-cpechart -- vtysh -c "show ip ospf neighbor"

echo ""
echo "## 8. Rutas CPE1"
microk8s kubectl exec -n $SDWNS deploy/cpe1-cpechart -- vtysh -c "show ip route"

echo ""
echo "## 9. Rutas CPE2"
microk8s kubectl exec -n $SDWNS deploy/cpe2-cpechart -- vtysh -c "show ip route"

echo ""
echo "## 10. NAT CPE1"
microk8s kubectl exec -n $SDWNS deploy/cpe1-cpechart -- iptables -t nat -L -n -v

echo ""
echo "## 11. NAT CPE2"
microk8s kubectl exec -n $SDWNS deploy/cpe2-cpechart -- iptables -t nat -L -n -v

echo ""
echo "## 12. OVS WAN1"
microk8s kubectl exec -n $SDWNS deploy/wan1-wanchart -- ovs-vsctl show

echo ""
echo "## 13. OVS WAN2"
microk8s kubectl exec -n $SDWNS deploy/wan2-wanchart -- ovs-vsctl show

echo ""
echo "## 14. Flujos WAN1"
microk8s kubectl exec -n $SDWNS deploy/wan1-wanchart -- ovs-ofctl -O OpenFlow13 dump-flows brwan

echo ""
echo "## 15. Flujos WAN2"
microk8s kubectl exec -n $SDWNS deploy/wan2-wanchart -- ovs-ofctl -O OpenFlow13 dump-flows brwan

echo ""
echo "## 16. Conectividad desde h1 hacia h2 e Internet"
sudo lxc-attach -n h1 -- ping -c 4 10.20.2.2
sudo lxc-attach -n h1 -- ping -c 4 8.8.8.8
sudo lxc-attach -n h1 -- traceroute 10.20.2.2

echo ""
echo "## 17. Conectividad desde h2 hacia h1 e Internet"
sudo lxc-attach -n h2 -- ping -c 4 10.20.1.2
sudo lxc-attach -n h2 -- ping -c 4 8.8.8.8
sudo lxc-attach -n h2 -- traceroute 10.20.1.2

echo ""
echo " VALIDACIÓN FINALIZADA"

