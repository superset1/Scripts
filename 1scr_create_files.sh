#!/bin/bash

mypath="/home/vitaly/Desktop/2/"

! [ -d "$mypath" ] && mkdir "$mypath"
 sudo chmod 777 $mypath

for i in {1..10}; do

  install -m 777 /dev/null "${mypath}test${i}.txt"

done
