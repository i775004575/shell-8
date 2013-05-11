#!/bin/bash
export LC_ALL=C

handle(){
file=$1
paixu=$2
awk '
{
	total++;
	uri=substr($7,0,index($7,"?")-1);
	if(uri==""){uri=substr($7,0,length($7)-1);}
	map0[uri]++;
	key=uri"~"$8$6;
	map1[key]+=$2;
	map2[key]++;
	map3[key]+=$9;
} 
END{
	for(k in map1){
		if(map2[k]>5){
			printf("%-65s\t %-4s\t %-4s\t %.1f%\t %d\t %.1f%\t %.1f\t %.1f\n",substr(k,0,index(k,"~")-1),
			substr(substr(k,index(k,"~")+1),0,3),substr(substr(k,index(k,"~")+1),5),
			map2[k]*100/map0[substr(k,0,index(k,"~")-1)],map2[k],map2[k]*100/total,
			map1[k]/(map2[k]*1000),map3[k]/(map2[k]*1000));
		}
	}
}' $file | sort -k${paixu}nr
}

path="/home/admin/cai/logs/cronolog"
year=`date +%Y`
month=`date +%m`
today=`date +%Y-%m-%d`
log=$path"/"$year"/"$month"/"$today"-taobao-access_log"
qps=`tsar -check | awk  'BEGIN{ RS="nginx/qps=[0-9.]+ "} { print RT }'| head -1|  awk -F"=" '{print $2}'`
count=`echo $qps*600 | bc | awk '{print int($1)}'`

########################
echo ""
echo ""
echo `date`
echo "------------------------------"
echo ""
echo "" | awk '{printf("%-65s\t %-4s\t %-4s\t %s\t %s\t %s\t %s\t %s\n","URL","Status","Method","S-Rate","PV","P-Rate","RT(ms)","Size(KB)") }' 
echo ""
echo  "===================================================================================================================================="
echo ""



if [ -z "$1" ];then
mode="-10mdef"
else
mode=$1
fi

paixu=`echo $2 | awk '
BEGIN{
	map["-sorturl"]="1";
	map["-sortpv"]="5";
	map["-sortrt"]="7";
	map["-sortsize"]="8";
}
{
	result=map[$1];
	if(result==""){
		result="5"
	}
	print result;
}'`


if [ $mode = "-10mdef" ];then
tail -"${count}"  $log | handle " "  $paixu
exit 1
fi
if [ $mode = "-pipe" ];then
handle " " $paixu
exit 1
fi
if [ $mode = "-def" ];then
log=$log
else
log=$1
fi
handle $log $paixu

