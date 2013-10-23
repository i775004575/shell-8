#!/bin/bash
export LC_ALL=C

###
###  items:  ip rt time date method url uri status size ref refuri ua extra all
###
###  sh sp.sh -def ip,time,ref 
###  sh sp.sh -deftail ip,time,ref 
###  sh sp.sh /home/admin/logs/access.log ip,time,ref 
###  cat access.log | sh sp.sh -pipe ip,time 
###

#####################CORE################
handle () {
items=$1
sep=$2
file=$3

awk -v sep="$sep" "
BEGIN{
	ORS=sep
}
{
	date=substr(\$4,2,11);
	\$4=substr(\$4,14);
	\$6=substr(\$6,2);
	\$7=substr(\$7,0,length(\$7)-1);
	uri=substr(\$7,0,index(\$7,\"?\")-1); 
	if(uri==\"\"){uri=\$7;}
	\$10=substr(\$10,2,length(\$10)-2);
	refuri=substr(\$10,0,index(\$10,\"?\")-1); 
	if(refuri==\"\"){refuri=\$10;}
	tmpr=\"\";
	for(i=11;i<=NF;i++){tmpr=tmpr\$i\" \";}
	tmpr=substr(tmpr,2,length(tmpr)-3);
	if(index(tmpr,\"\\\"\")>0){
		ua=substr(tmpr,0,index(tmpr,\"\\\"\")-1);
		extra=substr(\$NF,2,length(\$NF)-2);
	}else{
		ua=tmpr;
		extra=\"-\";
	}
	print $items
}"  $file
}

########START########

path="/home/admin/cai/logs/cronolog"
year=`date +%Y`
month=`date +%m`
today=`date +%Y-%m-%d`
defaultlog=$path"/"$year"/"$month"/"$today"-taobao-access_log"

log=$1
items=$2
sep=$3
if [ -z "$1" ];then
echo "Params Missing!!!"
exit 0
fi
if [ -z "$2" ];then
items="all"
fi
if [ -z "$3" ];then
sep="\n"
fi

items=`echo $items|awk -F"," '
BEGIN{
	map["all"]="$0";
	map["ip"]="$1";
	map["rt"]="$2";
	map["time"]="$4";
        map["date"]="date";
	map["method"]="$6";
	map["url"]="$7";
 	map["uri"]="uri";
	map["status"]="$8";
	map["size"]="$9";
	map["ref"]="$10";
	map["refuri"]="refuri";
        map["ua"]="ua";
	map["extra"]="extra";
}
{
	for(i=1;i<=NF;i++){
		res=res""map[$i]; 
		if(i<NF){res=res",";}
	}
}
END{
	print res;
}'`

if [ $log = "-pipe" ];then
handle $items "$sep"
elif [ $log = "-deftail" ];then
tail -f $defaultlog | handle $items "$sep"
elif [ $log = "-def" ];then
handle  $items "$sep" $defaultlog
else
handle  $items "$sep" $log
fi
