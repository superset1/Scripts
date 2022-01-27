#!/bin/bash

# Default shell for a new user
#sed -i 's/SHELL=\/bin\/sh/SHELL=\/bin\/bash/' /etc/default/useradd
sed -i '/SHELL=/s!/sh!/bash!' /etc/default/useradd
# Default shell for a new user

# Password complexity
sed -i 's/obscure/minlen=1/' /etc/pam.d/common-password
# Password complexity

# Don't block screen
gsettings set org.gnome.desktop.screensaver lock-enabled false
# Don't block screen

apt update # Update index
echo "y" | apt upgrade # Update installed packages 

snap install lxd || apt install -y lxd
apt install -y git
apt install -y lvm2
apt install -y openssh-server
#apt install -y iptables-persistent

### Ansible
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible
apt install -y python-pip # Package manager for Python packages
pip install "pywinrm>=0.3.0" # Ansible for Windows
### Ansible

### Iptables settings
sysctl -q -w net.ipv4.ip_forward=1 # Enaple NAT
sed -i 's/#net.ipv4.ip_forward=.*$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
iptables -F
iptables --table nat --append POSTROUTING --out-interface ens3 -j MASQUERADE  # NAT rule
iptables -A INPUT -p tcp --dport ssh -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport ssh -s 10.10.0.0/16 -j ACCEPT
iptables -A INPUT -p tcp --dport ssh -j DROP
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
### Iptables settings

### Network settings
echo "# Let NetworkManager manage all devices on this system
network:
  version: 2
#  renderer: NetworkManager
  renderer: networkd
  ethernets:
   ens33:
    dhcp4: yes
#    addresses: [ 192.168.1.101/24 ]
#    gateway4: 192.168.1.1
#    nameservers:
#     addresses: [ 192.168.1.1, 8.8.8.8 ]
"> /etc/netplan/01-network-manager-all.yaml
netplan apply
### Network settings

### Postgresql
if ! [[ `apt list --installed | grep postgres` ]]; then
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#apt-get update
apt-get -y install postgresql
fi
### Postgresql

### Mysql
apt install -y mysql-server
apt install -y mysql-client
### Mysql

### Zabbix
if ! [[ `apt list --installed | grep zabbix` ]]; then
wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb
apt update
apt install -y zabbix-server-mysql
apt install -y zabbix-frontend-php
apt install -y zabbix-agent
apt install -y zabbix-nginx-conf
apt install -y zabbix-sql-scripts

mysql -uroot -p"root" -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -uroot -p"root" -e "create user zabbix@localhost identified by 'zabbix';" #123 - password
mysql -uroot -p"root" -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"
#mysql -uroot -p"root" -e "grant all privileges on zabbix.* to zabbix@localhost'zabbix';"
mysql -uroot -p"root" -e "FLUSH PRIVILEGES;"
zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -uzabbix -p"zabbix" zabbix

sed -i 's/^# DBPassword=.*$/DBPassword=zabbix/' /etc/zabbix/zabbix_server.conf
sed -i -e 's/^#//g' -e '/listen *80/s/80/8888/' -e 's/example.com/myzabbix/' /etc/zabbix/nginx.conf
systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm
fi
### Zabbix
