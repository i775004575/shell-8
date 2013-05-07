#!/bin/bash

export LC_ALL=C

handle(){
awk '{total++;a=tolower(substr($7,0,index($7,"?")-1));if(a==""){a=substr($7,0,length($7)-1);}map0[a]++;a=a"~"$8;map1[a]+=$2;map2[a]++;map3[a]+=$9;} END{for(k in map1){if(map2[k]>5){printf("%-65s\t %s\t %.1f%\t %d\t %.1f%\t %.1f\t %.1f\n",substr(k,0,index(k,"~")-1),substr(k,index(k,"~")+1),map2[k]*100/map0[substr(k,0,index(k,"~")-1)],map2[k],map2[k]*100/total,map1[k]/(map2[k]*1000),map3[k]/(map2[k]*1000));}}}' | sort -k4nr
}

path="/home/admin/cai/logs/cronolog/"

year=`date +%Y`

month=`date +%m`

today=`date +%Y-%m-%d`

log=$path$year"/"$month"/"$today"-taobao-access_log"

########################

qps=` tsar -check | awk  'BEGIN{ RS="nginx/qps=[0-9.]+ "} { print RT }'| head -1|  awk -F"=" '{print $2}'`

count=`echo $qps*600 | bc `

count=`echo $count | awk -F'.' '{print $1}'`

echo ""

echo ""

echo `date`

echo "------------------------------"

echo ""
 
echo  ""| awk '{printf("%-65s\t %s\t %s\t %s\t %s\t %s\t %s\n","URL","Status","S-Rate","PV","P-Rate","RT(ms)","Size(KB)") }' 

echo ""

echo  "===================================================================================================================================="

echo ""

if [ -z "$1" ];then

tail -"${count}"  $log | handle 

exit 1

fi

if [ $1 = "-pipe" ];then

handle

exit 1

fi

if [ $1 = "all" ];then

log=$log

else

log=$1

fi

cat $log | handle

