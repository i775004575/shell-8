#!/usr/bin/expect  
set timeout 100  
spawn ssh -N -p xxx -v root@xxx.xxx.xxx.xxx -D 127.0.0.1:7070
expect "password:"  
send "mimimimimimimimimimi\r"  
interact
