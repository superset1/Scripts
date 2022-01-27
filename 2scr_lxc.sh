#!/bin/bash

### Input validation LXD
while : ; do
read -n1 -p "Do you want to configure the LXD? [y/n] " answer
 if    [[ "$answer" =~ [nN] ]]; then
          echo
          break
  elif [[ "$answer" =~ [^yY] ]]; then
          echo
	  echo "You pressed the wrong key!"
  else
	  echo
          lxd init
          break
 fi
done
### Input validation LXD

### Input validation LXC
while : ; do
read -p "Haw many containers create? " c
 if    [[ "$c" = 0 ]]; then
          echo
          echo "Ok, Bye..."
	  exit
  elif [[ "$c" =~ [^1-9] ]]; then
          echo "Enter number!"
  else 
	  echo
          break
 fi
done
### Input validation LXC

### Iptables settings
sysctl -q -w net.ipv4.ip_forward=1 # Enaple NAT
sed -i 's/#net.ipv4.ip_forward=.*$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
if ! grep -q MASQUERADE /etc/iptables/rules.v4; then
  #iptables -F
  iptables --table nat --append POSTROUTING --out-interface ens3 -j MASQUERADE  # NAT rule
  iptables -A INPUT -p tcp --dport ssh -s 192.168.1.0/24 -j ACCEPT
  iptables -A INPUT -p tcp --dport ssh -s 10.10.0.0/16 -j ACCEPT
  iptables -A INPUT -p tcp --dport ssh -j DROP
  mkdir -p /etc/iptables
  iptables-save > /etc/iptables/rules.v4
fi
### Iptables settings

### Configuration containers
interface=`ip -o link | awk -F": " '$2 ~ /^ens|^eth/ {print $2}'`
c_exists=`lxc ls | grep -c "CONTAINER"` # Number of existing containers
  for ((i=$c_exists+1; i<=$c+$c_exists; i++)); do
   lxc init ubuntu:18.04 c$i
   [[ `ip a | grep lxnet` ]] || lxc network create lxnet ipv4.address=10.10.20.1/24 ipv6.address=none ipv4.nat=false ipv6.nat=false ipv4.firewall=false ipv6.firewall=false
   lxc network attach lxnet c$i $interface
   lxc config device set c$i $interface ipv4.address 10.10.20.1$i
   lxc start c$i
   sleep 5
   lxc exec c$i -- apt install openssh-server -y
   lxc exec c$i -- usermod -l vitaly ubuntu
#   echo -e "1\n1\n" | lxc exec c$i -- passwd ubuntu
#   lxc exec c$i -- sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
   lxc exec c$i -- service ssh restart
   lxc file push /home/vitaly/.ssh/id_rsa.pub c$i/home/ubuntu/.ssh/authorized_keys
   echo "lxc container c$i created"
  done
### Configuration containers
ansible all -m ping
