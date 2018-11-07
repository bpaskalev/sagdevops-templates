#!/bin/bash -x
###############################################################################
#  Copyright 2013 - 2018 Software AG, Darmstadt, Germany and/or its licensors
#
#   SPDX-License-Identifier: Apache-2.0
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
###############################################################################

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
                echo addint $ALIAS to stacks
#                ALIAS=<pod_name>, e.g. is01-deployment.123123

		RELEASE=$(kubectl get pod -n  $NAMESPACE $SPM_HOSTNAME -o jsonpath='{.metadata.labels.release}') #10.3 // hard code, or it might come from the pod label
		STACK=$(kubectl get pod -n  $NAMESPACE $SPM_HOSTNAME -o jsonpath='{.metadata.labels.com\.softwareag\.stack}') #<from pod com.softwareag.stack label = stack>, e.g. solution1
		LAYER=$(kubectl get pod -n  $NAMESPACE $SPM_HOSTNAME -o jsonpath='{.metadata.labels.com\.softwareag\.layer}') # <from pod com.softwareag.layer label = layer>, e.g. is or um

		STAGE=$(kubectl get pod -n  $NAMESPACE $SPM_HOSTNAME -o jsonpath='{.metadata.labels.com\.softwareag\.stage}') #<from pod com.softwareag.stage label = stage>, e.g. dev
		TENANT=$(kubectl get pod -n  $NAMESPACE $SPM_HOSTNAME -o jsonpath='{.metadata.labels.com\.softwareag\.tenant}') #<from pod  com.softwareag.tenant label>, e.g. customer1

		# processing

		if ! sagcc get stacks $STACK # no stack yet
		then
		  # create new stack
		  sagcc create stacks alias=$STACK release=$RELEASE description="$TENANT $STACK in $STAGE"
		fi

		# core product component id
		COMPONENT=$(sagcc list inventory components nodeAlias=$ALIAS runtimeComponentCategory=PROCESS properties=runtimeComponent.id includeHeaders=false | grep -v SPM)

		if ! sagcc get stacks $STACK layers $LAYER nodes  # no layer yet
		then
		   # register layer
		   sagcc create stacks $STACK layers alias=$LAYER layerType=RUNTIME-EXISTING nodes=$ALIAS runtimeComponentId=$COMPONENT description="Layer of Kubernetes pods"
		else
		   # scale layer to more instances
		   sagcc create inventory components attributes $ALIAS $COMPONENT "com.softwareag.belongs_to=$STACK:$LAYER"
		fi

		# add some other general attributes
		sagcc create inventory components attributes $ALIAS $COMPONENT "com.softwareag.stage=$STAGE" "com.softwareag.tenant=$TENANT"

		# add infrastructure layer
		if ! sagcc get stacks $STACK layers $LAYER nodes 
		then
		   sagcc create stacks $STACK layers alias=$LAYER layerType=INFRA-EXISTING nodes=$ALIAS
		fi

		# some generic attributes for nodes
		sagcc create inventory components attributes $ALIAS OSGI-SPM  "com.softwareag.belongs_to=$STACK:Infrastructure" "com.softwareag.stage=$STAGE" "com.softwareag.tenant=$TENANT"


		# list current inventory

		sagcc list stacks $STACK
		sagcc list stacks $STACK layers
		sagcc list stacks $STACK nodes
		;;
	Killing)
		CONTAINER_IP=$(kubectl describe pod $SPM_HOSTNAME -n $NAMESPACE  | grep ^IP | tr -s " " | cut -f2 -d ' ')
		echo "removing $CONTAINER_IP with alias $ALIAS"
		$CC_CLI_HOME/bin/sagcc list landscape nodes --wait-for-cc
		$CC_CLI_HOME/bin/sagcc delete landscape nodes $ALIAS --force
		$CC_CLI_HOME/bin/sagcc list landscape nodes
		;;
	*)
		echo "Unknown action $ACTION"
esac

