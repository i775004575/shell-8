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
echo "\t1  \t翻墙"
echo "\t2  \t修改hosts文件"
echo "\t3  \t本机IP\n"
echo "\t4  \t启动Tomcat服务器"
echo "\t5  \t关闭Tomcat服务器\n"
echo "\t6  \t启动Tengine服务"
echo "\t7  \t关闭Tengine服务"
echo "\t8  \t重启Tengine服务\n"
echo "\t9 \t启动mysql服务"
echo "\t10 \t关闭mysql服务\n"
echo "\t11 \t启动FastCGI\n"
echo "\t99 \t寻找快捷方式\n"
echo "\t0  \texit\n"
echo "which One ?"
echo "=============================================="
read ans
else
	ans=$1
fi

case $ans in
1)
python /home/peiliping/dev/goagent/local/proxy.py
;;
2)
sudo gedit /etc/hosts
;;
3)
ifconfig
;;
4)
sh $TOMCATZSHPATH deploy
getstat java
;;
5)
kill -9 `pgrep java`
getstat java
;;
6)
sh $NGINXYSHPATH start
getstat nginx 
;;
7)
sh $NGINXYSHPATH stop
getstat nginx 
;;
8)
sh $NGINXYSHPATH restart
getstat nginx 
;;
9)
/etc/init.d/mysql start
;;
10)
sudo /etc/init.d/mysql stop
;;
11)
spawn-fcgi -a 127.0.0.1 -p 9000 -C 10 -u peiliping -f /usr/bin/php-cgi
;;
99)
nautilus /usr/share/applications/
;;
0)
 exit 0
;;
esac
