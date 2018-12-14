<!-- Copyright 2013 - 2018 Software AG, Darmstadt, Germany and/or its licensors

   SPDX-License-Identifier: Apache-2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and

     limitations under the License.                                                  

-->

# Deployments on Kubernetes

This is a Proff of Concept how to do autoregistration and autoderegistration dynamicly as new pods with SAG products are being started and stopped.
## Requirements

### Supported platforms

* Docker 17.09+
* Kubernetes x.x
## Installation instructions

1. build registrar service
```bash
# cd sagdevops-templates/infrastructure
# docker-compose build kube-registrar
```
2. prepare the stack
* go to stack folder
```bash
# cd sagdevops-templates/deployments/kubernetes/sag-um-is/
```
* create namespace, cc and registrar deployments with the whole entourage
```bash
# kubectl create -f ns-cc-reg.yml
```
* wait untill cc and registrar deployments are ready
```bash
# kubectl get pod -n um-is-namespace
NAME                             READY   STATUS    RESTARTS   AGE
cc-deployment-7fc865d9ff-kkk5l   1/1     Running   0          5m
registrar-7489bb458c-w2ml4       1/1     Running   0          5m
```
3. start is
```bash
# kubectl create -f is.yml
```
4. start um
```bash
# kubectl create -f um.yml
```


## Check if they are registered as hosts and added as layers in the stack
* get the cc pod name
```bash
]# kubectl get pod -n um-is-namespace
NAME                             READY   STATUS    RESTARTS   AGE
cc-deployment-7fc865d9ff-kkk5l   1/1     Running   0          36m
is-deployment-566f6bd4bd-qmxc8   1/1     Running   0          14m
registrar-7489bb458c-w2ml4       1/1     Running   0          36m
um-deployment-58bf7684cc-8dpsk   1/1     Running   0          12m
```

* get the nodes 
```bash
# kubectl exec -n um-is-namespace cc-deployment-7fc865d9ff-kkk5l sagcc get landscape nodes
Alias                           Status  Host            Port    Version
local                           ONLINE  localhost       8992    10.3.0.0.208
um-deployment-58bf7684cc-8dpsk  ONLINE  10.42.1.20      8092    10.3.0.0.208
is-deployment-566f6bd4bd-qmxc8  ONLINE  10.42.1.19      8092    10.3.0.0.208
```

* list the stacks and layers
```bash
# kubectl exec -n um-is-namespace cc-deployment-7fc865d9ff-kkk5l sagcc list stacks
Alias           Description                     Release
solution1       customer1 solution1 in dev      10.3
```
Name of the stack, description etc, are not hardcoded but defined as labels in pod definitions

* list the layers in the stack
```bash
# kubectl exec -n um-is-namespace cc-deployment-7fc865d9ff-kkk5l sagcc list stacks solution1 layers
Alias   Description                     Type
INFRA   Infrastructure layer            INFRASTRUCTURE
is      Layer of Kubernetes pods        RUNTIME
um      Layer of Kubernetes pods        RUNTIME
```
