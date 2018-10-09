FROM daerepository03.eur.ad.sag:4443/ccdevops/commandcentral-client:10.3
user root
run yum update -y
run yum install -y epel-release
run yum install -y jq
run curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/amd64/kubectl
run chmod +x kubectl
run mv ./kubectl /usr/local/bin/kubectl
user 1724
add --chown=1724:1724 *.sh /src/
run chmod +x /src/*.sh
cmd /src/entrypoint.sh
