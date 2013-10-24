#!/bin/bash
export LC_ALL=C

logfilepath=""
paixu=""
spstr=""

while getopts "f:s:S:" optname 
do 
    case "$optname" in
    "f")
	logfilepath=$OPTARG
        ;;
    "s")
	spstr=$OPTARG
	;;
    "S")
	paixu=$OPTARG
	;;
    esac
done 

paixu=`echo $paixu | awk '
	BEGIN{
                map["url"]="1";
                map["pv"]="5";
                map["rt"]="7";
                map["size"]="8";
        }
        {
                result=map[$1];
                if(result==""){
                        result="5"
                }
                print result;
        }'`

spstr=`echo $spstr | awk '{if($1==""){print " "}}' `

echo ""
echo ""
echo `date`
echo "------------------------------"
echo ""
echo "" | awk '{printf("%-65s\t %-4s\t %-4s\t %s\t %s\t %s\t %s\t %s\n","URL","Status","Method","S-Rate","PV","P-Rate","RT(ms)","Size(KB)") }' 
echo ""
echo  "===================================================================================================================================="
echo ""

awk -F"$spstr" '
{
	total++;
	url=$1;
	uri=substr(url,0,index(url,"?")-1);
        if(uri==""){uri=substr(url,0,length(url)-1);}
	method=$2;
	status=$3;
	cost=$4;
	size=$5;
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
}' $logfilepath | sort -k${paixu}nr
