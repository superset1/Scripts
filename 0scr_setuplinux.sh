#!/bin/bash

### Test server configuration
set -euo pipefail

### Some variables
cat <<EOF >> /home/vitaly/.bashrc
# My aliases
alias a="cd ~/Code/Ansible"
alias b="cd ~/Code/Bashscripts"
alias d="cd ~/Code/Docker"
alias j="cd ~/Code/Jenkins"
alias k="cd ~/Code/Kubernetes"
alias s="cd ~/Code/SQL"
alias c="clear"
alias ap="ansible-playbook"
alias jj="java -jar jenkins-cli.jar -s http://localhost:8080/"
alias sn="sudo shutdown now"
alias sr="sudo shutdown -r now"
alias rand="openssl rand -base64 32"
export EDITOR=nano
export JENKINS_USER_ID=vitaly
export JENKINS_API_TOKEN=
# My aliases

# Kubernetes
source <(kubectl completion bash)
alias k="kubectl"
alias kcgc="kubectl config get-contexts"
alias kcuc="kubectl config use-context"
alias kg="kubectl get"
alias kgd="kubectl get deploy"
alias kgp="kubectl get pods"
alias kgs="kubectl get secret"
alias kgsv="kubectl get services"
complete -F __start_kubectl k
# Kubernetes

# Helm
alias hl="helm list -a"
alias hh="helm history"
alias hr="helm rollback"
# Helm

# WB
alias wb="cd ~/WB"
alias wba="cd ~/WB/Ansible"
alias wbr="cd ~/WB/Ansible/roles/"
alias wbg="cd ~/WB/Git/"
alias wbk="cd ~/WB/Git/kargin.vitaliy/"
alias wbs="cd ~/WB/Git/suppliers-portal-ru/"
export VAULT_ADDR=""
export VAULT_TOKEN=""
export WB_GIT_TOKEN_READ=""
export WB_GITLAB_TOKEN_READ=""

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
echo "StrictHostKeyChecking accept-new" >> /home/vitaly/.ssh/config
echo "user root" >> /home/vitaly/.ssh/config
### Some variables

### Don't ask admins for password with sudo
sed -i 's/sudo.*ALL$/sudo   ALL=(ALL:ALL\) NOPASSWD:ALL/' /etc/sudoers
### Don't ask admins for password with sudo

### Editor nano to all user
while read myeditor ; do
[[ ! `grep "export EDITOR=nano" $myeditor` ]] && [[ `echo -e "\nexport EDITOR=nano" >> $myeditor` ]]
done < <(find /home/ -maxdepth 2 -name ".bashrc")
### Editor nano to all user

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
# echo "y" | apt upgrade # Update installed packages 

apt install -y python 3.9
apt install -y python-setuptools
pip install hvac 

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
# apt install -y iptables-persistent
apt install -y curl
apt install -y jq
apt install -y s3cmd
apt install -y pwgen
apt install -y apt-transport-https
snap install -y lxd || apt install -y lxd
### Istall pakages

### VirtualBox 6.1
virtualbox(){
sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" >> /etc/apt/sources.list.d/virtualbox.list'
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
apt-get update
apt-get install -y virtualbox-6.1
}
### VirtualBox 6.1

### Docker
apt-get remove -y docker docker-engine docker.io containerd runc
apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
### Docker

### Vault
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault
### Vault

### Kubernetes
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
mkdir -p /usr/local/bin/
mv ./minikube /usr/local/bin/
apt install -y conntrack

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
  && chmod +x kubectl
mv ./kubectl /usr/local/bin/kubectl
kubectl completion bash >/etc/bash_completion.d/kubectl

### Ansible
# apt install -y software-properties-common
# add-apt-repository --yes --update ppa:ansible/ansible
# apt install -y ansible
# apt install -y python3-pip
# apt install -y python-pip # Package manager for Python packages
# pip install "pywinrm>=0.3.0" # Ansible for Windows
# pip install virtualenv
### Ansible

### Ansible
# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# python3 get-pip.py
# python3 -m pip install ansible
# python3 -m pip install paramiko
### Ansible

### Ansible
add-apt-repository ppa:ansible/ansible
apt update
apt-get install -y ansible
### Ansible

### Jenkins
jenkins(){
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

### Iptables settings
iptables(){
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
if ! [[ -f /etc/systemd/system/iptables_restore.service ]]; then
      touch /etc/systemd/system/iptables_restore.service
      chmod 664 /etc/systemd/system/iptables_restore.service
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
fi
}
# Iptables restore service

### Network settings for netplan
netplan(){
cat <<EOF > /etc/netplan/01-network-manager-all.yaml
# This is the network config written by 'subiquity'
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
}
### Network settings for netplan

postgres(){
### Postgresql
if ! [[ `apt list --installed | grep postgres` ]]; then
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#apt-get update
apt-get -y install postgresql
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf
sed -i '/host    all.*32/ {s/127.*\/32/0.0.0.0\/0/; s/scr.*256/password/}' /etc/postgresql/*/main/pg_hba.conf
sudo -u postgres psql -c "create user vitaly with password '123' createdb;"
systemctl restart postgresql
fi
}
### Postgresql

### Mysql
mysql(){
apt install -y mysql-server
apt install -y mysql-client
echo "export sqlpass=123" >> /home/vitaly/.bashrc
echo "[client]
user=vitaly
password=123
" > /home/vitaly/.my.cnf
mysql -e "CREATE USER 'vitaly'@'%' IDENTIFIED BY '123';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'vitaly'@'%';"
mysql -e "FLUSH PRIVILEGES;"
sed -i '/^bind-address/s/127.*1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
### Mysql
}

### MongoDB
mongodb(){
curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt update
apt install -y mongodb-org
systemctl start mongod.service
systemctl enable mongod
mongo --eval 'db.runCommand({ connectionStatus: 1 })' # Testing mongodb: 
}
### MongoDB

## Redis
redis(){
apt install -y redis-server 
sed -i 's/supervised no/supervised systemd/' /etc/redis/redis.conf 
systemctl restart redis.service
}
## Redis

### Zabbix
zabbix(){
if ! [[ `apt list --installed | grep zabbix` ]]; then
wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb
apt update

apt install -y zabbix-server-pgsql
apt install -y php7.4-pgsql
# apt install -y zabbix-server-mysql
apt install -y zabbix-frontend-php
# apt install -y zabbix-apache-conf
apt install -y zabbix-nginx-conf
apt install -y zabbix-sql-scripts
apt install -y zabbix-agent

sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix
sudo -u postgres psql -c "ALTER USER zabbix with PASSWORD 'zabbix';"

# mysql -uroot -p"root" -e "create database zabbix character set utf8 collate utf8_bin;"
# mysql -uroot -p"root" -e "create user zabbix@localhost identified by 'zabbix';"
# mysql -uroot -p"root" -e "grant all privileges on zabbix.* to zabbix@localhost;"
# mysql -uroot -p"root" -e "FLUSH PRIVILEGES;"

zcat /usr/share/doc/zabbix-sql-scripts/postgresql/create.sql.gz | sudo -u zabbix psql zabbix

# zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -uzabbix -p"zabbix" zabbix

sed -i 's/^# DBPassword=.*$/DBPassword=zabbix/' /etc/zabbix/zabbix_server.conf
sed -i -e 's/^#//g' -e '/listen *80/s/80/8888/' -e 's/example.com/myzabbix/' /etc/zabbix/nginx.conf

systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm # apache2
systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm # apache2
fi
}
### Zabbix

### Add language
dpkg-reconfigure locales
### Add language
