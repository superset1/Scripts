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
  if ! grep -q MASQUERADE /etc/iptables/rules.v4; then
       sysctl -q -w net.ipv4.ip_forward=1 # Enaple NAT
       sed -i 's/#net.ipv4.ip_forward=.*$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
       iptables --table nat --append POSTROUTING --out-interface $interface -j MASQUERADE  # NAT rule
       mkdir -p /etc/iptables
       iptables-save > /etc/iptables/rules.v4
  fi
### Iptables settings for NAT

### Configuration containers
if [[ "$answer" -gt 0 ]]; then
      for ((i=$c_exists+1; i<=$answer+$c_exists; i++)); do
            lxc init ubuntu:20.04 c$i
            [[ `ip a | grep lxnet` ]] || lxc network create lxnet ipv4.address=10.10.20.1/24 ipv6.address=none ipv4.nat=false ipv6.nat=false ipv4.firewall=false ipv6.firewall=false
            lxc network attach lxnet c$i $interface
            lxc config device set c$i $interface ipv4.address 10.10.20.1$i
            lxc start c$i
            sleep 7
#            echo -e "1\n1\n" | lxc exec c$i -- passwd ubuntu
#            lxc exec c$i -- sed -i 's/*PasswordAuthentication*$/PasswordAuthentication no/' /etc/ssh/sshd_config
            lxc exec c$i -- sed -i 's/#PubkeyAuthentication.*$/PubkeyAuthentication yes/' /etc/ssh/sshd_config
            lxc exec c$i -- timedatectl set-timezone Europe/Kaliningrad
            lxc file push /home/vitaly/.ssh/id_rsa.pub c$i/home/ubuntu/.ssh/authorized_keys
            cat /var/lib/jenkins/.ssh/id_rsa.pub  | ssh -i /home/vitaly/.ssh/id_rsa -o StrictHostKeyChecking=no ubuntu@10.10.20.1$i "cat >> /home/ubuntu/.ssh/authorized_keys" &> /dev/null
            lxc exec c$i -- service ssh restart || service sshd restart
            echo -e "lxc container c$i created\n"
            iptables -t nat -A PREROUTING -d 192.168.1.131 -p tcp -m tcp --dport 800$i -j DNAT --to-destination 10.10.20.1${i}:80
            # iptables -t nat -A POSTROUTING -p tcp --sport 80 --dst 10.10.20.1$i -j SNAT --to-source 192.168.1.131:800$i
            iptables-save > /etc/iptables/rules.v4
      done
service network-manager restart
ansible-playbook ../Ansible/pb3_lxc_apt_install.yml
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
        ssh-keygen -f "/root/.ssh/known_hosts" -R "10.10.20.1$i" &> /dev/null
        ssh-keygen -f "/home/vitaly/.ssh/known_hosts" -R "10.10.20.1$i" &> /dev/null
        ssh-keygen -f "/var/lib/jenkins/.ssh/known_hosts" -R "10.10.20.1$i" &> /dev/null
        echo -e "Container № $i has been removed!"
        iptables -t nat -D PREROUTING -d 192.168.1.131 -p tcp -m tcp --dport 800$i -j DNAT --to-destination 10.10.20.1${i}:80
        iptables-save > /etc/iptables/rules.v4
  done
lxc ls
### LXC delete
