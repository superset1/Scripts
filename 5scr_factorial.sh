#!/bin/bash

# FIrst solution
for ((i=1, f=1; i<=$1; i++)); do
  f=$(($i * $f))
done

echo "Factorial in for = $f"

# Second solution
function factorial {

  if [[ $1 -lt 1 ]]; then 
        echo 1
   else result=$(factorial $(( $1 - 1 )))
        echo $(( $result * $1 ))
  fi
  
}

echo "Factorial in function = $(factorial $1)"
echo ----------------------------