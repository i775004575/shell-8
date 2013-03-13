#!/bin/bash

export LC_ALL=C

path="/home/admin/cai/logs/cronolog/"

year=`date +%Y`

month=`date +%m`

today=`date +%Y-%m-%d`

log=$path$year"/"$month"/"$today"-taobao-access_log"

########################

qps=` tsar -check | awk  'BEGIN{ RS="nginx/qps=[0-9.]+ "} { print RT }'| head -1|  awk -F"=" '{print $2}'`

count=`echo $qps*600 | bc `

count=`echo $count | awk -F'.' '{print $1}'`

echo "##########find the frequency of IP################"
echo ""

tail -"${count}"  $log | awk -F"\"| " '{ a=tolower(substr($8,0,index($8,"?")-1));if(a==""){ a=$8 ;}  print $1"_"a }' | sort | uniq -cd | sort -nr | fgrep -v "status.taobao" | head -10

echo ""
echo "##########whose user agent is blank###############"
echo ""

tail -"${count}"  $log | awk -F"\"" '{if($6=="-" || substr($6,0,4)=="Java" || substr($6,0,26)=="Jakarta Commons-HttpClient" || substr($6,0.13)=="Python-urllib" ) print $1,$2}' | awk -F"\"| " '{ a=tolower(substr($8,0,index($8,"?")-1));{ a=$8 ;} print $1"_"a }' | sort | uniq -cd |sort -nr | fgrep -v "status.taobao" |fgrep -v "http://_-"  |head -10

echo ""
