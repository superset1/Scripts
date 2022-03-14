#!/bin/bash

### Test server configuration

### Some variables
echo 'alias a="cd /home/vitaly/Code/Ansible"
alias b="cd /home/vitaly/Code/Bashscripts"
alias d="cd /home/vitaly/Code/Docker"
alias j="cd /home/vitaly/Code/Jenkins"
alias k="cd /home/vitaly/Code/Kubernetes"
alias s="cd /home/vitaly/Code/SQL"
alias c="clear"
alias jj="java -jar jenkins-cli.jar -s http://localhost:8080/"
export JENKINS_USER_ID=vitaly
export JENKINS_API_TOKEN=' >> /home/vitaly/.bashrc
echo "StrictHostKeyChecking accept-new" >> /home/vitaly/.ssh/config
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
echo "y" | apt upgrade # Update installed packages 

snap install -y lxd || apt install -y lxd
apt install -y tree
apt install -y htop
apt install -y mc
apt install -y ncdu
apt install -y mlocate
apt install -y git
apt install -y lvm2
apt install -y samba
apt install -y openssh-server
apt install -y net-tools
apt install -y iperf3
apt install -y iptables-persistent
apt install -y curl
apt install -y apt-transport-https
### Istall pakages

### Ansible
apt install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible
apt install -y python3-pip
apt install -y python-pip # Package manager for Python packages
pip install "pywinrm>=0.3.0" # Ansible for Windows
### Ansible

### Jenkins
apt install -y openjdk-11-jre-headless
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install -y jenkins
### Jenkins

### Iptables settings
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

### Network settings for netplan
echo "# Let NetworkManager manage all devices on this system
network:
  version: 2
#  renderer: NetworkManager
  renderer: networkd
  ethernets:
   $interface:
    dhcp4: no
    addresses: [ 192.168.1.131/24 ]
    gateway4: 192.168.1.1
    nameservers:
     addresses: [ 192.168.1.1, 8.8.8.8 ]
"> /etc/netplan/01-network-manager-all.yaml
netplan generate
netplan apply
### Network settings for netplan

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
### Postgresql

### Mysql
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

### Zabbix
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
### Zabbix

### Add language
dpkg-reconfigure locales
### Add language
