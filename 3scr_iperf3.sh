#!/bin/bash

### Checking hosts using ping and iperf3 utilities (database MySql)

# Enter your values here
  t=3600 # Waiting time between checks in seconds
  dbname="hosts"
  dbuser="vitaly"
  dbpassword="123"
# Enter your values here

for i in `mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "SELECT host_name FROM hostspeed;" -B --skip-column-names`; do  # Getting a list of hosts
  speedtest="" # Reset variable
  lastdate=`mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "SELECT date_system FROM hostspeed WHERE host_name='$i';" -B --skip-column-names` # Getting the last access timestamp

    if [[ $(( $(date +%s) - $lastdate )) -gt $t ]] ; then # If the time since the last check is more than $t, then do a check
          mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "UPDATE hostspeed SET date_check=NOW() WHERE host_name='$i';" # Access date and time update

      if ping -c 4 $i; then # If host is reachable
            mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "UPDATE hostspeed SET status='Available' WHERE host_name='$i';" # Update available status
            speedtest=$(iperf3 -c $i | awk '/sender/ {print $7}')
        if [[ $speedtest ]]; then # If var is not empty
              mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "UPDATE hostspeed SET speed='$speedtest' WHERE host_name='$i';" # Update speed
              mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "UPDATE hostspeed SET date_system='$(date +%s)' WHERE host_name='$i';" # Update date in Unix format
        fi

       else
            echo "$(date '+%d-%m-%Y_%H-%M-%S') Host $i is unreachable" >> unreachable.log # Write unreachable hosts to log file
            mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "UPDATE hostspeed SET status='NOT Available' WHERE host_name='$i';" # Update available status
      fi
    fi
done

### Checking hosts using ping and iperf3 utilities
