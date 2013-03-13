#!/bin/bash
export LC_ALL=C

###
###  items:  ip cost time method url status size ref ua  uri  refuri
###
###  sh sp.sh -def ip,time,ref 
###
###  cat access.log | sh sp.sh -pipe  ip,time 
###


handle () {
items=$1
sep=$2
awk -v sep="$sep" "BEGIN{ORS=sep}{date=substr(\$4,2,11);\$4=substr(\$4,14);\$6=substr(\$6,2);\$7=substr(\$7,0,length(\$7)-1);\$10=substr(\$10,2,length(\$10)-2);for(i=11;i<=NF;i++){r=r\$i\" \"}\$11=substr(r,2,length(r)-3);r=\"\";uri=tolower(substr(\$7,0,index(\$7,\"?\")-1)); if(uri==\"\"){ uri=\$7 }; refuri=tolower(substr(\$10,0,index(\$10,\"?\")-1)); if(refuri==\"\"){refuri=\$10 };print $items}"
}

path="/home/admin/cai/logs/cronolog/"
year=`date +%Y`
month=`date +%m`
today=`date +%Y-%m-%d`

log=$1
items=$2
items=`echo $items|awk -F"," 'BEGIN{map["ip"]="$1";map["cost"]="$2";map["time"]="$4";map["method"]="$6";map["url"]="$7";map["status"]="$8";map["size"]="$9";map["ref"]="$10";map["ua"]="$11";map["uri"]="uri";map["refuri"]="refuri";map["date"]="date"}{for(i=1;i<=NF;i++){res=res""map[$i]; if(i<NF)res=res","}}END{print res}'`

if [ -z "$3" ];then
sep="\n"
else
sep=$3
fi

if [ $1 = "-pipe" ];then
handle $items "$sep"
elif [ $1 = "-deftail" ];then
log=$path$year"/"$month"/"$today"-taobao-access_log"
tail -10f $log | handle $items "$sep"
elif [ $1 = "-def" ];then
log=$path$year"/"$month"/"$today"-taobao-access_log"
cat $log | handle  $items "$sep"
else
cat $log | handle  $items "$sep"
fi
