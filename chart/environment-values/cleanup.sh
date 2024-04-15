#!/bin/bash
[ -z "$NAMESPACE" ] && echo "No NAMESPACE set" && exit 1
ns="openwifi-$NAMESPACE"
echo "Cleaning up namespace $ns in 10 seconds..."
sleep 10
echo "- delete tip-openwifi helm release in $ns"
helm -n "$ns" delete tip-openwifi
if [[ "$1" == "full" ]] ; then
    echo "- delete $ns namespace in 30 seconds..."
    sleep 30
    echo "- delete $ns namespace"
    kubectl delete ns "$ns"
fi
echo "- cleaned up $ns namespace"
exit 0
