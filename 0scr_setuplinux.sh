#!/bin/bash

### Test server configuration
set -euo pipefail

### Bashrc
[[ $(grep "My aliases" ~/.bashrc ) ]] || cat <<EOF >> ~/.bashrc

# My aliases
color_green='\e[32m'
color_red='\e[31m'
color_magenta='\e[35m'
color_yellow='\e[93m'
color_normal='\e[0m'

export EDITOR=nano
export JENKINS_USER_ID="vitaly"
export JENKINS_API_TOKEN=""
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION=""

alias a="cd ~/Code/Ansible"
alias ap="ansible-playbook"
alias b="cd ~/Code/Bashscripts"
alias c="clear"
alias cp="cp -r"
alias j="cd ~/Code/Jenkins"
alias jj="java -jar jenkins-cli.jar -s http://localhost:8080/"
alias k="cd ~/Code/Kubernetes"
tshl() { tsh login --proxy=${1}:443 --auth=local --user=superset ${1} ;}
pingw(){ for ping_server in ${@}; do while ! ping -c 1 $ping_server &> /dev/null; do sleep 1; done; echo -e "${color_magenta}$ping_server ${color_green}is reachable.${color_normal}"; done ;}
alias s="cd ~/Code/SQL"
be() { [[ $1 == '-f' ]] && echo -n "$(cat $2)" | base64 -w 0 || echo -n "$1" | base64 -w 0; echo ;}
bek() { python3 ~/WB/Git/kargin.vitaliy/scripts/base64_decode.py -e "${@:2}" ;}
bd() { echo -n "$1" | base64 -d; echo ;}
bdk() { [[ ${1::1} == '{' ]] && python3 ~/WB/Git/kargin.vitaliy/scripts/base64_decode.py "$1" || python3 ~/WB/Git/kargin.vitaliy/scripts/base64_decode.py ${namespace} $1 ;}
alias sn="sudo shutdown now"
alias sr="sudo shutdown -r now"
alias sshadd='cat /root/.ssh/id_ed25519.pub | ansible all -i hosts -m lineinfile -a "path=/root/.ssh/authorized_keys line=\"$(cat -)\" state=present" -e ansible_user=admin --become'
alias rand="openssl rand -base64 32"
# My aliases

# Docker
alias d="docker"
alias db="docker build . -t"
alias dc="docker commit"
alias de="docker exec -it"
alias dh="docker history"
alias di="docker images"
alias dia="docker images -a"
alias din="docker inspect"
alias dinsha='docker inspect -f "{{.RepoDigests}}"'
alias dK="docker kill"
alias dp="docker ps"
alias dpa="docker ps -a"
alias dpl="docker pull"
alias dP="docker system prune"
alias dr="docker run"
alias drd="docker run -d"
alias drdr="docker run -d --rm"
alias dri="docker run -it"
alias drir="docker run -it --rm"
alias dR="docker rm"
alias dRf="docker rm -f"
alias dRa='docker rm $(docker ps -qa)'
alias dRaf='docker rm -f $(docker ps -qa)'
alias dRI="docker rmi"
alias dRIf="docker rmi -f"
alias dRIa='docker rmi $(docker images -qa)'
alias dRIaf='docker rmi -f $(docker images -qa)'
alias ds="docker search"
alias dsh="docker show"
alias dt="docker tag"
alias dv="docker volume ls"
alias dvP="docker volume prune"
alias dvR="docker volume rm"
alias dvRf="docker volume rm -f"
alias dV="docker version"
# Docker

# Git
alias ga="git add ."
alias gb="git branch"
alias gba="git branch -a"
alias gbD="git branch -d"
gbDp() { git branch -d $1 && git push origin -d ;}
alias gbr="git branch -r"
alias gd="git diff"
alias gc="git add .; git commit"
alias gcp="git add .; git commit; git push"
alias gcpf="git add .; git commit; git push -f"
alias gca="git add .; git commit --amend"
alias gcap="git add .; git commit --amend --no-edit; git push -f"
alias gch="git checkout"
alias gchb="git checkout -b"
# gch(){ git checkout $@; git branch ;}
# gchb(){ git checkout -b $@; git branch ;}
alias gcl="git clone"
alias gf="git fetch"
alias gfa="git fetch --all"
alias gi="git init"
alias gl="git log"
alias gm="git merge"
alias gp="git push"
alias gpa="git push --all"
alias gpD="git push origin -d"
alias gpf="git push -f"
alias gpl="git pull"
alias gpl="git pull --all"
alias gr="git remote -v"
alias gra="git remote add"
alias grR="git remote remove"
alias gR="git restore"
alias gRH="git reset --hard"
alias gRs="git restore --staged"
alias gRS="git reset --soft"
alias gs="git status"
alias gsh="git show"
alias gt="git tag"
alias gta="git tag -a"
gtap() { if [[ $# -ge 1 ]]; then ([[ $# -eq 1 ]] && git tag -a $1; [[ $# -eq 2 ]] && git tag -m "$1" -a $2); git push origin --tags; else echo -e "${color_red}Enter tag name [and message]: ${color_yellow}git tag [-m \$1] -a \$2${color_normal}"; fi ;}
alias gtD="git tag -d"
alias gtp="git push origin --tags"
# Git

# Kubernetes
source <(kubectl completion bash)
ns() { if [[ $# -eq 1 ]]; then export namespace="-n $1"; echo -e ${color_normal}; kubectl get pods ${namespace}; fi; [[ $# -le 1 ]] && . ~/.bashrc && echo -e "${color_green}\nYour current context: ${color_magenta}$(kubectl config current-context)${color_normal}\n${color_green}\nYour current namespace: ${color_yellow}${namespace:3}${color_normal}\n" || echo -e "${color_red}Enter namespace only!${color_normal}" ;}
alias k="kubectl ${namespace}"
alias ka="kubectl apply ${namespace}"
alias kad="kubectl apply --dry-run=client ${namespace}"
alias kc="kubectl create ${namespace}"
kcac(){ bash ~/WB/Git/kargin.vitaliy/scripts/kubernetes_add_context_from_vault.sh "$@"; [ $# -eq 1 ] && [ $1 != '-h' ]&& ns $(echo $1 | awk -F/ '{print $NF}'); [ $1 == '-j' ] && ns $(echo $2 | jq -r '.namespace'); [ $# -eq 4 ] && ns $2 ;}
alias kcgc="kubectl config get-contexts"
kcuc() { [[ $# -eq 0 ]] && kubectl config get-contexts && echo -en "\n${color_green}Choose context: ${color_yellow}" && read context_temp && echo -e ${color_normal} || context_temp=$1; [[ -n $context_temp ]] && kubectl config use-context ${context_temp:-$1} && kubectl get namespaces && echo -en "\n${color_green}Choose namespace: ${color_yellow}" && read namespace_temp; ns ${namespace_temp:-${namespace:3}}; [[ $(grep -v "tele.*wb.ru" <<<${context_temp:-$1}) ]] && export namespace="-n $(echo ${context_temp:-$1} | awk -F. '{print $1}')" && kubectl get pods ${namespace}; echo -ne ${color_normal}; unset context_temp; unset namespace_temp; . ~/.bashrc ;}
alias kcucl="kcuc tele.dl.wb.ru-k8s.portal-dl"
alias kcucp="kcuc tele.dp.wb.ru-k8s.portal-dp"
alias kcucs="kcuc tele.dp.wb.ru-k8s.stage-dp"
alias kd="kubectl describe ${namespace}"
alias kdcm="kubectl describe cm ${namespace}"
alias kdd="kubectl describe deploy ${namespace}"
alias kde="kubectl describe events ${namespace}"
alias kdi="kubectl describe ingress ${namespace}"
alias kdn="kubectl describe nodes ${namespace}"
alias kdns="kubectl describe namespaces ${namespace}"
alias kdp="kubectl describe pods ${namespace}"
alias kdq="kubectl describe quota ${namespace}"
alias kdr="kubectl describe role ${namespace}"
alias kdrs="kubectl describe rs ${namespace}"
alias kds="kubectl describe services ${namespace}"
alias kdsc="kubectl describe secret ${namespace}"
alias kdv="kubectl describe vpa ${namespace}"
alias kD="kubectl delete ${namespace}"
alias kDd="kubectl delete deploy ${namespace}"
alias kDp="kubectl delete pods ${namespace}"
alias kDs="kubectl delete services ${namespace}"
alias kDsc="kubectl delete secret ${namespace}"
alias kDv="kubectl delete vpa ${namespace}"
alias ke="kubectl edit ${namespace}"
alias kecm="kubectl edit cm ${namespace}"
alias ked="kubectl edit deploy ${namespace}"
alias kei="kubectl edit ingress ${namespace}"
alias kep="kubectl edit pods ${namespace}"
alias keq="kubectl edit quota ${namespace}"
alias ker="kubectl edit role ${namespace}"
alias kers="kubectl edit rs ${namespace}"
alias kes="kubectl edit services ${namespace}"
alias kesc="kubectl edit secret ${namespace}"
alias kev="kubectl edit vpa ${namespace}"
alias kex="kubectl exec -it ${namespace}"
alias kexp="kubectl explain pods ${namespace}"
alias kg="kubectl get ${namespace}"
alias kgcm="kubectl get cm ${namespace}"
alias kgd="kubectl get deploy ${namespace}"
alias kgdn="kubectl get deploy --no-headers -o custom-columns=':metadata.name' ${namespace}"
alias kgdc="kubectl get deploy -o jsonpath-as-json='{.spec.template.spec.containers[*].name}{.spec.template.spec.initContainers[*].name}' ${namespace}"
alias kgdr="kubectl get deploy -o jsonpath-as-json='{range .spec.template.spec.containers[*]}{.name}{.resources}{end}{range .spec.template.spec.initContainers[*]}{.name}{.resources}{end}' ${namespace}"
alias kgdra="kubectl get deploy -o jsonpath-as-json='{range .items[*].spec.template.spec}{range .containers[*]}{.name}{.resources}{end}{range .initContainers[*]}{.name}{.resources}{end}' ${namespace}"
alias kgdy="kubectl get deploy -o yaml ${namespace}"
alias kge='kubectl get events --sort-by=".metadata.creationTimestamp" ${namespace}'
alias kgev='kubectl get events --sort-by=".metadata.creationTimestamp" ${namespace} --field-selector reason=EvictedByVPA'
alias kgi="kubectl get ingress ${namespace}"
alias kgn="kubectl get nodes ${namespace}"
kgns() { if [[ $# -ge 1 ]]; then kubectl get namespaces $@; else kubectl get namespaces; echo -en "\n${color_green}Choose namespace: ${color_yellow}"; read namespace_temp; ns $namespace_temp; unset namespace_temp; echo -en ${color_normal}; fi ;}
alias kgo="bash ~/WB/Git/kargin.vitaliy/scripts/kubernetes_get_objects_yaml.sh"
alias kgp="kubectl get pods ${namespace}"
alias kgpo="kubectl get pods -o wide ${namespace}"
alias kgpc="kubectl get pods -o jsonpath-as-json='{.spec.containers[*].name}{.spec.initContainers[*].name}' ${namespace}"
alias kgpr="kubectl get pods -o jsonpath-as-json='{range .spec.containers[*]}{.name}{.resources}{end}{range .spec.initContainers[*]}{.name}{.resources}{end}' ${namespace}"
alias kgq="kubectl get quota ${namespace}"
alias kgr="kubectl get role ${namespace}"
alias kgrs="kubectl get rs ${namespace}"
alias kgs="kubectl get services ${namespace}"
alias kgsc="kubectl get secret ${namespace}"
alias kgscy="kubectl get secret -o yaml ${namespace}"
alias kgv="kubectl get vpa ${namespace}"
alias kgvy="kubectl get vpa -o yaml ${namespace}"
alias kl="kubectl logs ${namespace}"
kld() { kubectl logs deploy/$1 ${namespace} ;}
alias kR="kubectl rollout ${namespace}"
alias kRhd="kubectl rollout history deploy ${namespace}"
# kRRd() { [[ $# -ne 1 ]] && echo -e "${color_red}kubectl rollout restart deploy: Enter deploy!${color_normal}" || kubectl rollout restart deploy $1 ${namespace} ;}
# kRsd() { [[ $# -ne 1 ]] && echo -e "${color_red}kubectl rollout status deploy: Enter deploy!${color_normal}" || kubectl rollout status deploy $1 ${namespace} ;}
alias kRRd="kubectl rollout restart deploy ${namespace}"
alias kRsd="kubectl rollout status deploy ${namespace}"
kRUd() { [[ $# -ne 2 ]] && echo -e "${color_red}kubectl rollout undo deploy: Enter deploy and revision!${color_normal}" || kubectl rollout undo deploy $1 --to-revision $2 ${namespace} ;}
kSd() { [[ $# -ne 2 ]] && echo -e "${color_red}kubectl scale deploy: Enter deploy and replicas!${color_normal}" || kubectl scale deploy $1 --replicas=$2 ${namespace} ;}
kSda() { [[ $# -ne 1 ]] && echo -e "${color_red}kubectl scale deploy: Enter number of replicas!${color_normal}" || for deploy_full_name in $(kubectl get deploy -o name ${namespace}); do kubectl scale $deploy_full_name --replicas=$1 ${namespace}; done ;}
alias ktn="kubectl top nodes ${namespace}"
alias ktp="kubectl top pod ${namespace}"
complete -F __start_kubectl k
# Kubernetes

# Helm
source <(helm completion bash)
alias h="helm ${namespace}"
alias hc="helm create ${namespace}"
alias hg="helm get ${namespace}"
alias hga="helm get all ${namespace}"
alias hgm="helm get manifest ${namespace}"
alias hgv="helm get values ${namespace}"
alias hh="helm history ${namespace}"
alias hi="helm install ${namespace}"
alias hl="helm list -a ${namespace}"
alias hln="helm lint ${namespace}"
alias hp="helm package ${namespace}"
hra() { [[ $# -ne 2 ]] && echo -e "${color_red}helm repo add: Enter name and url!${color_normal}" || helm repo add $1 $2 ;}
alias hrl="helm repo list"
alias hrR="helm repo remove"
alias hru="helm repo update"
alias hR="helm rollback ${namespace}"
alias hs="helm status ${namespace}"
alias hsr="helm search repo"
alias hsh="helm search hub"
alias ht="helm template ${namespace}"
alias hu="helm upgrade ${namespace}"
alias huR="helm upgrade --reset-values ${namespace}"
alias hU="helm uninstall --keep-history ${namespace}"
alias hU!="helm uninstall ${namespace}"
# alias hU="bash ~/WB/Git/kargin.vitaliy/scripts/helm_uninstall.sh"
complete -F __start_helm h
# Helm

# Vault
alias vkg="vault kv get"
alias vkp="vault kv put"
alias vsl="vault secrets list"
vtn() { sed -i "s/^export VAULT_TOKEN.*/export VAULT_TOKEN=\"$1\"/" ~/.bashrc && . ~/.bashrc ;}
# Vault

# WB
alias wb="cd ~/WB"
alias wbap="cd ~/WB/Ansible/products/"
alias wbar="cd ~/WB/Ansible/roles/"
alias wbg="cd ~/WB/Git/"
alias wbgd="cd ~/WB/Git/devops"
alias wbgs="cd ~/WB/Git/wb-certs/"
alias wbi="cd ~/WB/Git/devops/infrastructure/ansible/inventory/projects/portals/"
alias wbk="cd ~/WB/Git/kargin.vitaliy/"
alias wbks="cd ~/WB/Git/kargin.vitaliy/scripts"
export VAULT_ADDR="https://vault.wildberries.ru:8200"
export VAULT_TOKEN=""
export WB_GIT_TOKEN_READ=""
export WB_GITLAB_TOKEN_READ=""
export WB_GITLAB_SESSION=""
# WB

# History
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
HISTSIZE=50000
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1) HISTSIZE=1000
HISTFILESIZE=50000
# append to the history file, don't overwrite it
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r"
# History
EOF
### Bashrc

### SSH Config
[[ $(grep "StrictHostKeyChecking accept-new") ]] || cat <<EOF >> ~/.ssh/config
StrictHostKeyChecking accept-new
user root
EOF
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/ssh_config
### SSH Config

### Crontab
cat <<EOF | crontab -
0 10 * * * cp -r ~/.kube/config ~/WB/Config/.kube/
EOF
### Crontab

### Git Config
[[ $(grep "Vitaly Kargin" ~/.gitconfig) ]] || cat <<EOF > ~/.gitconfig
[user]
	name = Vitaly Kargin
	email = super_set@mail.ru
EOF
### Git Config

### Don't ask admins for password with sudo
sed -i 's/sudo.*ALL$/sudo   ALL=(ALL:ALL\) NOPASSWD:ALL/' /etc/sudoers
### Don't ask admins for password with sudo

### Timezone Kaliningrad
#sudo ln -sf /usr/share/zoneinfo/Europe/Kaliningrad /etc/localtime 
sudo timedatectl set-timezone Europe/Kaliningrad
### Timezone Kaliningrad

### Default shell for a new user
sed -i '/SHELL=/s!/sh!/bash!' /etc/default/useradd
### Default shell for a new user

### Password complexity off
sed -i 's/obscure/minlen=1/' /etc/pam.d/common-password
### Password complexity off

### Don't block screen
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
### Don't block screen

### Istall pakages
apt update # Update index packages

apt install -y python3.9 python-setuptools python3-pip
pip install --upgrade requests python-gitlab hvac paramiko molecule ansible-core ansible-lint molecule-docker molecule-vagrant

apt install -y shellcheck
apt install -y htop
apt install -y testdisk
apt install -y tree
apt install -y mc
apt install -y ncdu
apt install -y rename
apt install -y mlocate
apt install -y git
apt install -y lvm2
apt install -y samba
apt install -y openssh-server
apt install -y net-tools
apt install -y iperf3
apt install -y curl
apt install -y jq
apt install -y s3cmd
apt install -y pwgen
apt install -y apt-transport-https
apt install -y vagrant && vagrant autocomplete install --bash --zsh
apt install -y virtualbox
snap install lxd || apt install -y lxd
### Istall pakages

### VirtualBox 6.1
# echo "Install VirtualBox"
# sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" >> /etc/apt/sources.list.d/virtualbox.list'
# wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
# apt-get update
# apt-get install -y virtualbox-6.1
### VirtualBox 6.1

### Docker
echo "Install Docker"
# apt-get remove -y docker docker-engine docker.io containerd runc
apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
### Docker

### Vault
echo "Install Vault"
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault
sudo apt-add-repository -r "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
### Vault

### Kubernetes
echo "Install Kubernetes"
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
mkdir -p /usr/local/bin/
mv ./minikube /usr/local/bin/
apt install -y conntrack

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
  && chmod +x kubectl
mv ./kubectl /usr/local/bin/kubectl
kubectl completion bash >/etc/bash_completion.d/kubectl
### Kubernetes

### Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm
### Helm


### Ansible
echo "Install Ansible"
add-apt-repository -y ppa:ansible/ansible
apt update
apt-get install -y ansible
apt install -y ansible-lint
### Ansible

### Network settings for netplan
echo "Configure Netplan"
cat <<EOF > /etc/netplan/01-network-manager-all.yaml
# This is the network config written by 'Vitaly Kargin'
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: yes
      dhcp4-overrides:
        route-metric: 100
    ens37:
      dhcp4: no
      addresses:
      - 192.168.1.131/24
      dhcp4-overrides:
        route-metric: 200
EOF
netplan generate
netplan apply
### Network settings for netplan

### Iptables settings
iptables(){
echo "Configure Iptables"
apt install -y iptables-persistent
interface=`ip -o link | awk -F": " '$2 ~ /^ens|^eth/ {print $2; exit; }'`
# sysctl -q -w net.ipv4.ip_forward=1 # Enaple NAT
sed -i 's/#net.ipv4.ip_forward=.*$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p
iptables -F # Reset rules
iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE  ### NAT rule
# iptables -A INPUT -p tcp --dport ssh -s 192.168.1.0/24 -j ACCEPT
# iptables -A INPUT -p tcp --dport ssh -s 10.10.0.0/16 -j ACCEPT
# iptables -A INPUT -p tcp --dport ssh -j DROP
# iptables -A FORWARD -i ens33 -o ens38 -j ACCEPT
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
service network-manager restart
### Iptables settings

# Iptables restore service
[[ -f /etc/systemd/system/iptables_restore.service ]] ||
      touch /etc/systemd/system/iptables_restore.service &&
      chmod 664 /etc/systemd/system/iptables_restore.service &&
      cat <<EOF > /etc/systemd/system/iptables_restore.service
[Unit]
Description=Iptables restore after reboot
After=network.target docker.service
#After=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/usr/sbin/iptables-restore /etc/iptables/rules.v4

[Install]
WantedBy=multi-user.target
EOF
      systemctl enable iptables_restore.service
      # systemctl start iptables_restore.service
}
# Iptables restore service

### Jenkins
jenkins(){
echo "Install Jenkins"
apt install -y openjdk-11-jre-headless
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install -y jenkins
}
### Jenkins

### Postgresql
postgres(){
echo "Install Postgresql"
[[ `apt list --installed | grep postgres` ]] ||
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' &&
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - &&
#apt-get update &&
apt-get -y install postgresql &&
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf &&
sed -i '/host    all.*32/ {s/127.*\/32/0.0.0.0\/0/; s/scr.*256/password/}' /etc/postgresql/*/main/pg_hba.conf &&
sudo -u postgres psql -c "create user vitaly with password '123' createdb;" &&
systemctl restart postgresql
}
### Postgresql

### MySQL
mysql(){
echo "Install MySQL"
apt install -y mysql-server
apt install -y mysql-client
echo "export sqlpass=123" >> ~/.bashrc
echo "[client]
user=vitaly
password=123
" > ~/.my.cnf
mysql -e "CREATE USER 'vitaly'@'%' IDENTIFIED BY '123';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'vitaly'@'%';"
mysql -e "FLUSH PRIVILEGES;"
sed -i '/^bind-address/s/127.*1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
### MySQL
}

### MongoDB
mongodb(){
echo "Install MongoDB"
curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt update
apt install -y mongodb-org
systemctl start mongod.service
systemctl enable mongod
mongo --eval 'db.runCommand({ connectionStatus: 1 })' # Testing mongodb: 
}
### MongoDB

### MongoDB Shell
echo "Install MongoDB Shell"
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
sudo apt update
sudo apt-get install -y mongodb-mongosh
### MongoDB Shell

### Redis
echo "Install Redis"
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install -y redis
# sed -i 's/supervised no/supervised systemd/' /etc/redis/redis.conf 
# systemctl restart redis.service
### Redis

### Zabbix
zabbix(){
echo "Install Zabbix"
[[ `apt list --installed | grep zabbix` ]] ||
wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb &&
dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb &&
apt update &&

apt install -y zabbix-server-pgsql &&
apt install -y php7.4-pgsql &&
# apt install -y zabbix-server-mysql &&
apt install -y zabbix-frontend-php &&
# apt install -y zabbix-apache-conf &&
apt install -y zabbix-nginx-conf &&
apt install -y zabbix-sql-scripts &&
apt install -y zabbix-agent &&

sudo -u postgres createuser --pwprompt zabbix &&
sudo -u postgres createdb -O zabbix zabbix &&
sudo -u postgres psql -c "ALTER USER zabbix with PASSWORD 'zabbix';" &&

# mysql -uroot -p"root" -e "create database zabbix character set utf8 collate utf8_bin;" &&
# mysql -uroot -p"root" -e "create user zabbix@localhost identified by 'zabbix';" &&
# mysql -uroot -p"root" -e "grant all privileges on zabbix.* to zabbix@localhost;" &&
# mysql -uroot -p"root" -e "FLUSH PRIVILEGES;" &&

zcat /usr/share/doc/zabbix-sql-scripts/postgresql/create.sql.gz | sudo -u zabbix psql zabbix &&

# zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -uzabbix -p"zabbix" zabbix &&

sed -i 's/^# DBPassword=.*$/DBPassword=zabbix/' /etc/zabbix/zabbix_server.conf &&
sed -i -e 's/^#//g' -e '/listen *80/s/80/8888/' -e 's/example.com/myzabbix/' /etc/zabbix/nginx.conf &&

systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm # apache2 &&
systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm # apache2
}
### Zabbix

### Add language
dpkg-reconfigure locales
### Add language

apt-get clean
apt-get autoremove