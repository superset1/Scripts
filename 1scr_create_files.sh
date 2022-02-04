#!/bin/bash

### Create empty files and set permissions

mypath="/home/vitaly/Generating_folder/"
! [ -d "$mypath" ] && mkdir "$mypath"
  sudo chmod 777 $mypath
for i in {1..10}; do
      install -m 777 /dev/null "${mypath}test${i}.txt"
done