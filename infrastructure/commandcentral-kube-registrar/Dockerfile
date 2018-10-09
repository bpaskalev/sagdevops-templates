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
FROM daerepository03.eur.ad.sag:4443/ccdevops/commandcentral-client:10.3
user root
run yum update -y &&\
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/amd64/kubectl &&\
    chmod +x kubectl &&\
    mv ./kubectl /usr/local/bin/kubectl
user 1724
add --chown=1724:1724 *.sh /src/
run chmod +x /src/*.sh
cmd /src/entrypoint.sh
