#!/bin/bash
export LC_ALL=C

logfilepath=""
conffilepath=""
logformatstr=""
items=""
spstr=""

while getopts "f:c:m:i:s:" optname 
do 
    case "$optname" in 
    "f") 
	logfilepath=$OPTARG
        ;; 
    "c")
	conffilepath=$OPTARG
	;;
    "m")
	logformatstr=$OPTARG
	;;
    "i")
	items=$OPTARG
	;;
    "s")
	spstr=$OPTARG
	;;
    esac 
done 

items=`awk -v its="$items" -v fmt="$logformatstr" -v spstr="$spstr" -F'=' '
BEGIN{
	split(its,arrayitems,",");
	split(fmt,target,spstr);
	for(i=1;i<=length(target);i++){
		list[target[i]]="$"i;
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

awk -F"$spstr" "{print $items}" $logfilepath
