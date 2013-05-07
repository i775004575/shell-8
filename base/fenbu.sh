#!/bin/bash
export LC_ALL=C

unit=$1
file=$2
ignore=$3

if [ -z "$ignore" ];then
ignore="0.1"
fi


echo "==============================================================================="
echo ""
echo "" | awk '{printf("%-30s\t %-15s\t %s\t %s\n","Range","Times","Rate","AddUpRate");}'
echo ""
echo "==============================================================================="

awk -v unit="$unit" '{key=$1/unit;printf("%d\n",key)}' $file | awk -v unit="$unit"  -v ignore="$ignore" 'BEGIN{max=0;min=0}{map[$1]++;total++;if($1>max){max=$1;}if($1<min){min=$1;}}END{tmp=0;tmp2=0;start=0;end=0;for(i=min;i<=max;i++){if(map[i]!=""){tmp=tmp+map[i];tmp2=tmp2+map[i];if(map[i]*100/total>ignore||i==max){end=i+1;printf("%-30s\t %-15s\t %.2f%\t %.2f%\n",start*unit"~"end*unit,tmp2,tmp2*100/total,tmp*100/total);start=i+1;tmp2=0;}}}}'
