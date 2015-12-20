#!/bin/bash
export LC_ALL=C

##params

pid=$1
level=$2
trytimes=$3
onlyrunnable=$4

if [ -z "$pid" ] ;then
 echo "enter pid"
 exit 0
fi
if [ -z "$level" ] ;then
 level=50
fi
if [ -z "$trytimes" ] ;then
 trytimes=10000
fi
if [ -z "$onlyrunnable" ] ;then
 onlyrunnable="true"
fi

##job

for i in `seq $trytimes`
do
 time=`date +%s`"_"`date +%N`
 restop=`top -p $pid -b -H -d 1 -n 1 | head -8 | tail -1`
 nid=`echo $restop | awk '{print $1}'`
 cpu=`echo $restop | awk '{print $9}'`
 occur=`expr $cpu \> $level`
 nid16="nid=0x"`echo $nid | awk '{printf "%x",$1}'`
 if [ $occur = "1"  ] ;then
  jstack $pid | awk -v key=$nid16 -v onlyrunnable=$onlyrunnable '
    {
	if(status=="true"){
		if($0==""){
			print "";
			exit;
		}else{
			print $0;
			if(handlestatus=="true"){
				handlestatus="false";
				if(onlyrunnable=="true"&&$2!="RUNNABLE"){
					status="";
					next;
				}
			}
			next;
		}
	}
	match($0,key);
	if(RSTART>0){
		print $0;
		status="true";
		handlestatus="true";
	}
    }'
 fi
 sleep 1
done
