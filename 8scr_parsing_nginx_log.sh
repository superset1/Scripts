#!/bin/bash

### Blocking multiple requests to nginx after 2 minutes and unblocking after 10 minutes
### This script can be added to the crontab

request_timer=120
unblock_timer=600
request_counter=10

# Adding tracking logs for the iptables
if ! [[ -f /etc/rsyslog.d/iptables.conf ]]; then
        touch /var/log/iptables.log
        echo ':msg, contains, "Iptables: " -/var/log/iptables.log' > /etc/rsyslog.d/iptables.conf
        echo '& ~' >> /etc/rsyslog.d/iptables.conf
cat <<EOF > /etc/logrotate.d/iptables
/var/log/iptables.log {
    hourly
    rotate 1
    compress
    missingok
    notifempty
    sharedscripts
}
EOF
        systemctl restart rsyslog.service
fi
# Adding tracking logs for the iptables

# Reading entries in the nginx_log file for the last 2 minutes
while read nginx_log; do
     nginx_log_time=$(echo $nginx_log | cut -d " " -f 1-4 | cut -d ":" -f 2-4)
       if [[ $(date +%s)-$(date --date="$nginx_log_time" '+%s') -lt "$request_timer" ]]; then
          nginx_log_2m+=$(echo -e "\n$nginx_log")
        else break  
       fi
done < <(tac /var/log/nginx/access.log)
# Reading entries in the nginx_log file for the last 2 minutes

iptables_ip=$(iptables -S | grep -oE "INPUT.*--dports 80,443 -j DROP" | awk '{print $3}' | cut -d "/" -f 1)
nginx_log_ip=$(echo "$nginx_log_2m"| awk '{print $1}' | sort)
# Blocking IP addresses in the iptable if there are more than 10 requests in the last 2 minutes
for nginx_log_ip_uniq in $(echo "$nginx_log_ip" | uniq); do
     if [[ $(grep -c "$nginx_log_ip_uniq" <<< "$nginx_log_ip") -gt "$request_counter" ]] && [[ "$iptables_ip" != *"$nginx_log_ip_uniq"* ]]; then
           iptables -I INPUT -p tcp -m multiport --dport 80,443 -s $nginx_log_ip_uniq -j DROP
           iptables -I INPUT -p tcp -m multiport --dport 80,443 -s $nginx_log_ip_uniq -m limit --limit 6/min -j LOG --log-prefix "Iptables: Block ip scan: "          
     fi
done
# Blocking IP addresses in the iptable if there are more than 10 requests in the last 2 minutes

# Reading entries in the iptables_log file for the last 10 minutes
while read iptables_log; do
     iptables_log_time=$(echo $iptables_log | awk '{print $3}')
       if [[ $(date +%s)-$(date --date="$iptables_log_time" '+%s') -lt "$unblock_timer" ]]; then
             iptables_log_10m+=$(echo -e "\n$iptables_log")
        else break  
       fi
done < <(tac /var/log/iptables.log)
# Reading entries in the iptables_log file for the last 10 minutes

# Unblocking IP addresses in the iptable if there no requests in the last 10 minutes
for unblock_ip in $iptables_ip; do
  if [[ "$iptables_log_10m" != *"$unblock_ip"* ]]; then
        iptables -D INPUT -p tcp -m multiport --dport 80,443 -s $unblock_ip -j DROP
        iptables -D INPUT -p tcp -m multiport --dport 80,443 -s $unblock_ip -m limit --limit 6/min -j LOG --log-prefix "Iptables: Block ip scan: "
  fi
done
# Unblocking IP addresses in the iptable if there no requests in the last 10 minutes