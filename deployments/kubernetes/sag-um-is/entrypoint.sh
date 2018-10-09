#!/bin/bash
echo entry
export CA_CERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
export TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
export NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
## todo wait for cc to become available
export CC_SERVER=$(kubectl describe pod -n $NAMESPACE $(kubectl get pod -n $NAMESPACE | grep cc-deployment | cut -f1 -d " ") | grep ^IP | tr -s " " | cut -f2 -d " ")
env
while true
do 
	kubectl get events  -n $NAMESPACE    --watch-only=true --no-headers=true | egrep --line-buffered "\ Started\ |\ Killing\ " | xargs -r -L1 /src/process_event.sh
done
sleep 10000
