#!/bin/bash
export LC_ALL=C

file=$1
unit=$2
ignore=$3

if [ -z "$unit" ];then
unit="1"
fi
if [ -z "$ignore" ];then
ignore="0.1"
fi

echo "==============================================================================="
echo ""
echo "" | awk '{printf("%-30s\t %-15s\t %s\t %s\n","Range","Times","Rate","AddUpRate");}'
echo ""
echo "==============================================================================="

awk -v unit="$unit"  -v ignore="$ignore" '
BEGIN{
	max="";min="";
}
{
	$1=int($1/unit);
	map[$1]++;total++;
	if($1>max){max=$1;}
	if($1<min||min==""){min=$1;}
}
END{
	tmp1=0;tmp2=0;start=0;
	for(i=min;i<=max;i++){
		if(map[i]!=""){
			tmp1=tmp1+map[i];tmp2=tmp2+map[i];
			if(map[i]*100/total>ignore||i==max){
				printf("%-30s\t %-15s\t %.2f%\t %.2f%\n",start*unit"~"(i+1)*unit,tmp2,tmp2*100/total,tmp1*100/total);
				start=i+1;tmp2=0;
			}
		}
	}
}' $file
