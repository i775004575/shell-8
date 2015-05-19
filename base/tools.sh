#!/bin/bash

TOMCATZSHPATH="/home/peiliping/dev/tomcat7/bin/z.sh"
NGINXYSHPATH="/usr/local/nginx/sbin/y.sh"

getstat(){
sleep 1s
ps -ef | fgrep $1
}

if [ -z "$1" ] ;then
clear
echo "=============================================="
echo "\n"
echo "\t1  \t本机IP"
echo "\t2  \t修改hosts文件"
echo "\t3  \t寻找快捷方式\n"
echo "\t0  \texit\n"
echo "which One ?"
echo "=============================================="
read ans
else
	ans=$1
fi

case $ans in
1)
ifconfig
;;
2)
sudo gedit /etc/hosts
;;
3)
nautilus /usr/share/applications/
;;
0)
 exit 0
;;
esac
