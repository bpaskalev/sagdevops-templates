#!/bin/bash -x
echo processing:

SPM_HOSTNAME=$(echo $4 | cut -d '.' -f 1)
APPNAME=$(echo $6 | tr "\}" "\{" | cut -d '{' -f 2)
ACTION=$8
FIRST_SEEN=$2

[[ "$FIRST_SEEN" != *"s" ]] && exit
[[ "$APPNAME" == "registrar" ]] && exit
[[ "$APPNAME" == "cc" ]] && exit

echo $SPM_HOSTNAME
echo $APPNAME
echo $ACTION
echo $NAMESPACE


DESCRIPTION="Automatically_added"
#ALIAS=$APPNAME
ALIAS=$SPM_HOSTNAME
CONTAINER_IP=$(kubectl describe pod $SPM_HOSTNAME -n $NAMESPACE  | grep ^IP | tr -s " " | cut -f2 -d ' ')

case $ACTION in
	Started)
		for i in {1..20}
		do
		        kubectl get pod -n $NAMESPACE $SPM_HOSTNAME  --no-headers=true | grep Running  > /dev/null && break
		        sleep 5
		done
		CONTAINER_IP=$(kubectl describe pod $SPM_HOSTNAME -n $NAMESPACE  | grep ^IP | tr -s " " | cut -f2 -d ' ')

		echo "adding $CONTAINER_IP with alias $ALIAS"
		$CC_CLI_HOME/bin/sagcc list landscape nodes --wait-for-cc
		$CC_CLI_HOME/bin/sagcc add landscape nodes alias=$ALIAS url="http://$CONTAINER_IP:8092" description=$DESCRIPTION -e OK -w 180 -c 20
		$CC_CLI_HOME/bin/sagcc list landscape nodes
		;;
	Killing)
		echo "removing $CONTAINER_IP with alias $ALIAS"
		$CC_CLI_HOME/bin/sagcc list landscape nodes --wait-for-cc
		$CC_CLI_HOME/bin/sagcc delete landscape nodes $ALIAS --force
		$CC_CLI_HOME/bin/sagcc list landscape nodes
		;;
	*)
		echo "Unknown action $ACTION"
esac

