#!/bin/bash

export LC_ALL=C

path=$1

stime=$2

r1=`du -h -k  --max-depth=1  $path `

sleep $stime

r2=`du -h -k  --max-depth=1  $path `

clear

echo ""

echo "Path  "$path

echo "======================================================================"

echo ""| awk '{printf("%-40s\t %s\t %s\n","FileName","IncrementSize","") }'

echo "======================================================================"

rr=`echo "${r1}";echo "${r2}"`

echo "$rr" | awk '{if(map[$2]=="") map[$2]=0-$1; else map[$2]=$1+map[$2]; } END{ for(m in map){ if(map[m]!=0) printf("%-40s\t %.2f %s\n",m,map[m],"K")} }' | sort -k2nr
