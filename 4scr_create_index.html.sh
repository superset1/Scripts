#!/bin/bash


echo "-------------------------"
cat <<EOF > index.html
<html>
<body bgcolor=black>
<center>
<h2> <font color=yellow>Hello World </font></h2>
</center>
<font color=green> Hi </font>
</body>
</html>
EOF
echo "-------------------------"


echo "-------------------------"
result=$(grep "Hello" index.html)
echo $result
if [[ $result =~ "Hello" ]]; then
echo "Test passed"
exit 0
else
echo "Test failed"
exit 1
fi
echo "-------------------------"
