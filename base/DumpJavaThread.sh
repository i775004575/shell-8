#!/bin/bash

export LC_ALL=C

level="10"
path="/tmp/dump_log_jstack/"
rm -rf $path
mkdir $path
file="d_"
pid=`ps -ef | fgrep jboss  | fgrep java | awk '{print $2}'`

for i in `seq 100`
do
time=`date +%s`"_"`date +%N`
rtop=`top -p $pid  -H -d 1 -n 1 | head -8 | tail -1`
ppid=`echo $rtop | awk '{print $1}'`
cpu=`echo $rtop | awk '{print $9}' | awk -F"." '{print $1}'`
istrue=`expr $cpu \> $level`
if [ $istrue = "1"  ] ;then
echo $rtop >> $path$file$time
echo $ppid | awk '{print substr($0,7)}' |awk '{printf "%x\n",$0}' >>$path$file$time
/opt/taobao/java/bin/jstack `ps -ef | fgrep jboss  | fgrep java | awk '{print $2}'`   >> $path$file$time
fi
done
