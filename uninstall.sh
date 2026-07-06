#!/bin/bash

set -u # to verify variables are defined
: $SDWNS

# HELM SECTION
for NETNUM in {1..2}
do
  for VNF in access cpe wan
  do
    helm -n $SDWNS uninstall $vnf$NETNUM 2>/dev/null || true
  done
done

microk8s kubectl delete deployments --all