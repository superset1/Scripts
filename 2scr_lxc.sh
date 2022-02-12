#!/bin/bash

### Creating containers from initial configuration
### Author Vitaly Kargin

# Include input validation function
source lib1_inputvalidation.lib # Returns $answer
# Include input validation function

# LXD initial configuration
echo
validinput "Do you want to configure the LXD? [y/n] " "yY" "lxd init" "nN" "Ok"
# LXD initial configuration

c_exists=`lxc ls | grep -c "CONTAINER"` # Number of existing containers
echo -e "\nYou have $c_exists containers."
lxc ls

# LXC create
echo
validinput "How many containers create? " "1-9" "" "0" "Ok"
# LXC create

### Iptables settings for NAT
interface=`ip -o link | awk -F": " '$2 ~ /^ens|^eth/ {print $2; exit; }'`
sysctl -q -w net.ipv4.ip_forward=1 # Enaple NAT
sed -i 's/#net.ipv4.ip_forward=.*$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
  if ! grep -q MASQUERADE /etc/iptables/rules.v4; then
#       iptables -F # Reset rules
       iptables --table nat --append POSTROUTING --out-interface $interface -j MASQUERADE  # NAT rule
#       iptables -A INPUT -p tcp --dport ssh -s 192.168.1.0/24 -j ACCEPT
#       iptables -A INPUT -p tcp --dport ssh -s 10.10.0.0/16 -j ACCEPT
#       iptables -A INPUT -p tcp --dport ssh -j DROP
       mkdir -p /etc/iptables
       iptables-save > /etc/iptables/rules.v4
  fi
### Iptables settings for NAT

### Configuration containers
if [[ "$answer" -gt 0 ]]; then
      for ((i=$c_exists+1; i<=$answer+$c_exists; i++)); do
            lxc init ubuntu:18.04 c$i
            [[ `ip a | grep lxnet` ]] || lxc network create lxnet ipv4.address=10.10.20.1/24 ipv6.address=none ipv4.nat=false ipv6.nat=false ipv4.firewall=false ipv6.firewall=false
            lxc network attach lxnet c$i $interface
            lxc config device set c$i $interface ipv4.address 10.10.20.1$i
            lxc start c$i
            sleep 7
#            echo -e "1\n1\n" | lxc exec c$i -- passwd ubuntu
#            lxc exec c$i -- sed -i 's/*PasswordAuthentication*$/PasswordAuthentication no/' /etc/ssh/sshd_config
            lxc exec c$i -- timedatectl set-timezone Europe/Kaliningrad
            lxc exec c$i -- sed -i 's/#PubkeyAuthentication.*$/PubkeyAuthentication yes/' /etc/ssh/sshd_config
            lxc exec c$i -- service ssh restart || service sshd restart
            lxc file push /home/vitaly/.ssh/id_rsa.pub c$i/home/ubuntu/.ssh/authorized_keys
            echo -e "lxc container c$i created\n"
      done
service network-manager restart
lxc ls
exit
fi
### Configuration containers

### LXC delete
echo
validinput "How many containers delete? " "1-9" "" "0" "Ok, bye...\n" "exit"

  for ((i=$c_exists; i>$c_exists-$answer; i--)); do
        lxc stop c$i
        lxc delete c$i
        echo -e "Container $i has been removed!"
  done
lxc ls
### LXC delete
