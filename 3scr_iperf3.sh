#!/bin/bash

### Checking hosts using ping and iperf3 utilities (database MySql)
### If you need a SQL script to create a database, download the MySQL_create_db_hosts_for_iperf3.sql file from my SQL repository

# Enter your values here
  t=3600 # Waiting time between checks in seconds
  dbname="testhosts"
  dbuser="vitaly"
  dbpassword="123"
# Enter your values here

mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "INSERT IGNORE INTO iperf3 (host_name) SELECT host_name FROM hostlist;" # Insert unique host list

for i in `mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "SELECT host_name FROM iperf3;" -B --skip-column-names`; do  # Getting a list of hosts from iperf3 table
  speedtest="" # Reset variable
  lastdate=`mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "SELECT date_system FROM iperf3 WHERE host_name='$i';" -B --skip-column-names` # Getting the last access timestamp
  
    if [[ $(( $(date +%s) - $lastdate )) -gt $t ]] ; then # If the time since the last check is more than $t, then do a check
          mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "UPDATE iperf3 SET date_check=NOW() WHERE host_name='$i';" # Access date and time update

      if ping -c 4 $i; then # If host is reachable
            mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "UPDATE iperf3 SET status='Available' WHERE host_name='$i';" # Update available status
            speedtest=$(iperf3 -c $i | awk '/sender/ {print $7, $8}') # Run iperf3 command
        if [[ $speedtest ]]; then # If var is not empty
              mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "UPDATE iperf3 SET speed='$speedtest' WHERE host_name='$i';" # Update speed
              mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "UPDATE iperf3 SET date_system='$(date +%s)' WHERE host_name='$i';" # Update date in Unix format
        fi

       else
            mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "UPDATE iperf3 SET status='NOT Available' WHERE host_name='$i';" # Update available status
            mysql -u"$dbuser" -p"$dbpassword" -D "$dbname" -e "INSERT INTO unavailable_log SET host_name='$i';" # UpWrite unreachable hosts to database
            echo "$(date '+%d-%m-%Y_%H-%M-%S') Host $i is unreachable" >> unreachable.log # Write unreachable hosts to log file
      fi
    fi

done

### Checking hosts using ping and iperf3 utilities