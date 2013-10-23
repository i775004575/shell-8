#!/bin/bash
export LC_ALL=C

logfilepath=""
conffilepath=""
logformatstr=""
logformatfile=""
spstr=""

while getopts "f:c:m:s:" optname 
do 
    case "$optname" in
    "f")
	logfilepath=$OPTARG
        ;;
    "c")
	conffilepath=$OPTARG
	;;
    "m")
	logformatfile=$OPTARG
	logformatstr=`awk -F'=' '$1=="format"{print $2}' $logformatfile`
	;;
    "s")
	spstr=$OPTARG
	;;
    esac
done 

items="vhost,uri,method,status,cost,size"

items=`awk -v its="$items" -v fmt="$logformatstr" -v spstr="$spstr" -F'=' '
BEGIN{
	split(its,arrayitems,",");
	split(fmt,target,spstr);
	for(i=1;i<=length(target);i++){
		list[target[i]]=i;
	}
}
{
	map[$2]=$1;
}
END{
	res="";
	for(i=1;i<=length(arrayitems);i++){
		res=res""list[map[arrayitems[i]]];
		if(i<length(arrayitems)){res=res",";}
	}
	print res;
}' $conffilepath`

pvhost=`echo $items|awk -F"," '{print $1}'`
puri=`echo $items| awk -F"," '{print $2}'`
pmethod=`echo $items| awk -F"," '{print $3}'`
pstatus=`echo $items| awk -F"," '{print $4}'`
pcost=`echo $items| awk -F"," '{print $5}'`
psize=`echo $items| awk -F"," '{print $6}'`

echo ""
echo ""
echo `date`
echo "------------------------------"
echo ""
echo "" | awk '{printf("%-65s\t %-4s\t %-4s\t %s\t %s\t %s\t %s\t %s\n","URL","Status","Method","S-Rate","PV","P-Rate","RT(ms)","Size(KB)") }' 
echo ""
echo  "===================================================================================================================================="
echo ""

awk -v pvhost="$pvhost" -v puri="$puri" -v pmethod="$pmethod" -v pstatus="$pstatus" -v pcost="$pcost" -v psize="$psize" -F"$spstr" '
{
	total++;
	uri=$pvhost$puri;
	method=$pmethod;
	status=$pstatus;
	cost=$pcost;
	size=$psize;
	map0[uri]++;
	key=uri"~"status""method;
	map1[key]+=cost;
	map2[key]++;
	map3[key]+=size;
} 
END{
	for(k in map1){
		if(map2[k]>0){
			printf("%-65s\t %-4s\t %-4s\t %.1f%\t %d\t %.1f%\t %.1f\t %.1f\n",substr(k,0,index(k,"~")-1),
			substr(substr(k,index(k,"~")+1),0,3),substr(substr(k,index(k,"~")),5),
			map2[k]*100/map0[substr(k,0,index(k,"~")-1)],map2[k],map2[k]*100/total,
			map1[k]/(map2[k]*1000),map3[k]/(map2[k]*1000));
		}
	}
}' $logfilepath

