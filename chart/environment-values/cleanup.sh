#!/bin/bash
[ -z "$NAMESPACE" ] && echo "No NAMESPACE set" && exit 1
helm -n openwifi-$NAMESPACE delete tip-openwifi
sleep 30
kubectl delete ns openwifi-$NAMESPACE
