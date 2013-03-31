#!/bin/bash
export LC_ALL=C

##params
level=$1
if [ -z "$level" ] ;then
level=10
fi
trytimes="1000"

##prepare 4 dump
path="/tmp/dump_log_jstack/"
rm -rf $path
mkdir $path
file="d_"
pid=`ps -ef | fgrep jboss  | fgrep java | awk '{print $2}'`


for i in `seq $trytimes`
do
time=`date +%s`"_"`date +%N`
rtop=`top -p $pid  -H -d 1 -n 1 | head -8 | tail -1`
ppid=`echo $rtop | awk '{print $1}' | awk '{print substr($0,7)}'`
cpu=`echo $rtop | awk '{print $9}' | awk -F"." '{print $1}'`
istrue=`expr $cpu \> $level`
if [ $istrue = "1"  ] ;then
/opt/taobao/java/bin/jstack `ps -ef | fgrep jboss  | fgrep java | awk '{print $2}'`   >> $path$file$time
echo $rtop >> $path$file$time
echo $ppid |awk '{printf "%x\n",$0}' >>$path$file$time
echo "Bingo Bingo"
fi
remain=`expr $trytimes - $i`
echo $remain
done
