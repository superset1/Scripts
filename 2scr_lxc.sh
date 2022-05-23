#!/bin/bash

### Creating containers for Ubuntu
### Author Vitaly Kargin

# Include input validation function
source lib1_inputvalidation.lib # Returns $answer
# Include input validation function

set -euo pipefail

# Variables
obraz=$(lxc image ls -c l -f csv | grep superset) || obraz='images:ubuntu/21.10' # obraz='images:alpine/3.15/cloud'
server_interface=`ip -o link | awk -F": " '$2 ~ /^ens|^eth/ {print $2; exit; }'`
container_interface="eth0"
c_exists=`lxc ls | grep -c "CONTAINER"` # Number of existing containers
# Variables

# LXD initial configuration
if [[ ${1:-} == "init" ]]; then
      echo
      validinput "Do you want to configure the LXD? [y/n] " "yY" "" "nN" "Ok"
      if [[ $answer == [yY] ]]; then
            cat <<EOF | lxd init --preseed
config: {}
networks:
- config:
    ipv4.address: 10.10.20.1/24
    ipv4.nat: "true"
    ipv6.address: none
  description: ""
  name: lxnet
  type: bridge
  project: default
storage_pools:
- config:
    lvm.thinpool_name: LXDThinPool
    lvm.vg_name: lvm-pool
    size: 5GB
    source: /var/snap/lxd/common/lxd/disks/lvm-pool.img
  description: ""
  name: lvm-pool
  driver: lvm
profiles:
- config:
    limits.cpu: "1"
    limits.memory: 2GB
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxnet
      type: nic
    root:
      path: /
      pool: lvm-pool
      type: disk
  name: default
projects:
- config:
    features.images: "true"
    features.networks: "true"
    features.profiles: "true"
    features.storage.volumes: "true"
  description: Default LXD project
  name: default
EOF
      fi
fi
# LXD initial configuration

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
# Iptables restore service

echo -e "\nYou have $c_exists containers."
lxc ls

# LXC create
echo
validinput "How many containers create? " "1-9" "" "0" "Ok"
# LXC create

### Iptables settings for NAT
if ! grep -q MASQUERADE /etc/iptables/rules.v4; then
      sysctl -q -w net.ipv4.ip_forward=1 # Enaple NAT
      sed -i 's/#net.ipv4.ip_forward=.*$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
      sudo iptables --table nat --append POSTROUTING --out-interface $server_interface -j MASQUERADE  # NAT rule
      mkdir -p /etc/iptables
      sudo iptables-save > /etc/iptables/rules.v4
fi
### Iptables settings for NAT

### Configuration containers
if [[ "$answer" -gt 0 ]]; then
      for ((i=$c_exists+1; i<=$answer+$c_exists; i++)); do
            lxc init $obraz c$i
            [[ `ip a | grep lxnet` ]] || lxc network create lxnet ipv4.address=10.10.20.1/24 ipv6.address=none ipv4.nat=false ipv6.nat=false ipv4.firewall=false ipv6.firewall=false
            lxc network attach lxnet c$i $container_interface
            lxc config device set c$i $container_interface ipv4.address 10.10.20.1$i
            lxc start c$i
            sleep 7
#            echo -e "1\n1\n" | lxc exec c$i -- passwd ubuntu
#            lxc exec c$i -- sed -i 's/*PasswordAuthentication*$/PasswordAuthentication no/' /etc/ssh/sshd_config
            lxc exec c$i -- apt install -y openssh-server
            lxc exec c$i -- sed -i 's/#PubkeyAuthentication.*$/PubkeyAuthentication yes/' /etc/ssh/sshd_config
            lxc exec c$i -- timedatectl set-timezone Europe/Kaliningrad
            cat /home/$USER/.ssh/id_ed25519.pub | lxc exec c$i -- bash -c 'mkdir /root/.ssh; cat >> /root/.ssh/authorized_keys'
            # [[ -f /var/lib/jenkins/.ssh/id_rsa.pub ]] && cat /var/lib/jenkins/.ssh/id_rsa.pub  | lxc exec c$i -- bash -c 'mkdir /root/.ssh; cat >> /root/.ssh/authorized_keys' &> /dev/null
            lxc exec c$i -- systemctl restart sshd
            echo -e "lxc container c$i created\n"
            sudo bash -c "echo 10.10.20.1$i c$i >> /etc/hosts"
            sudo iptables -t nat -A PREROUTING -d 192.168.1.131 -p tcp -m tcp --dport 801$i -j DNAT --to-destination 10.10.20.1${i}:80
            sudo iptables -t nat -A PREROUTING -d 192.168.1.131 -p tcp -m tcp --dport 201$i -j DNAT --to-destination 10.10.20.1${i}:22
            # iptables -t nat -A POSTROUTING -p tcp --sport 80 --dst 10.10.20.1$i -j SNAT --to-source 192.168.1.131:800$i
      done
# service network-manager restart
sudo bash -c 'iptables-save > /etc/iptables/rules.v4'
# ansible-playbook ../Ansible/pb3_lxc_apt_install.yml
lxc ls
exit
fi
### Configuration containers

### LXC delete
echo
while : ; do
  validinput "How many containers delete? " "1-9" "" "0" "Ok, bye...\n" "exit"
  [[ $answer > $c_exists ]] && echo -e "You have $c_exists containers only!\n" || break
done
  for ((i=$c_exists; i>$c_exists-$answer; i--)); do
        lxc stop c$i
        lxc delete c$i
        # ssh-keygen -f "/root/.ssh/known_hosts" -R "10.10.20.1$i" &> /dev/null
        ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "10.10.20.1$i" &> /dev/null
        # ssh-keygen -f "/var/lib/jenkins/.ssh/known_hosts" -R "10.10.20.1$i" &> /dev/null
        sudo sed -i "/10.10.20.1$i/d" /var/snap/lxd/common/lxd/networks/lxnet/dnsmasq.leases
        sudo sed -i "/10.10.20.1$i/d" /etc/hosts
        echo -e "Container № $i has been removed!"
        sudo iptables -t nat -D PREROUTING -d 192.168.1.131 -p tcp -m tcp --dport 801$i -j DNAT --to-destination 10.10.20.1${i}:80
        sudo iptables -t nat -D PREROUTING -d 192.168.1.131 -p tcp -m tcp --dport 201$i -j DNAT --to-destination 10.10.20.1${i}:22
        sudo bash -c 'iptables-save > /etc/iptables/rules.v4'
  done
lxc ls
### LXC delete
