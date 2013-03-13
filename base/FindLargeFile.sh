#!/bin/bash

export LC_ALL=C

path=$1

stime=$2

r1=`ls -al $path | awk '{print $5,$9}'`

sleep $stime

r2=`ls -al $path | awk '{print $5,$9}'`

clear

echo ""

echo "Path  "$path

echo "======================================================================"

echo ""| awk '{printf("%-40s\t %s\t %s\n","FileName","IncrementSize","") }'

echo "======================================================================"

echo "$r1" "$r2" | awk '{if(map[$2]=="") map[$2]=0-$1; else map[$2]=$1+map[$2]; } END{ for(m in map){ if(map[m]!=0) printf("%-40s\t %.2f %s\n",m,map[m]/1000,"K")} }' | sort -k2nr
