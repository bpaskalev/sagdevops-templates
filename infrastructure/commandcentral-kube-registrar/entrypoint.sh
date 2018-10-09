#!/bin/bash
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
