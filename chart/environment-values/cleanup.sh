#!/bin/bash
[ -z "$NAMESPACE" ] && echo "No NAMESPACE set" && exit 1
echo "Deleting openwifi-$NAMESPACE"
helm -n openwifi-$NAMESPACE delete tip-openwifi
sleep 15
echo "Deleting namespace openwifi-$NAMESPACE"
kubectl delete ns openwifi-$NAMESPACE
exit 0
