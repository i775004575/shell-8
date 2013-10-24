#!/bin/bash
export LC_ALL=C

logfilepath=""
conffilepath=""
logformatstr=""
logformatfile=""
items=""
outputspstr=""

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
	logformatfile=$OPTARG
	logformatstr=`awk -F'=' '$1=="format"{print $2}' $logformatfile`
	;;
    "i")
	items=$OPTARG
	;;
    "s")
	outputspstr=$OPTARG
	;;
    esac
done 

outputspstr=`echo $outputspstr | awk '{if($1==""){print " "}}' `

items=`awk -v its="$items" -F'=' '
BEGIN{
	split(its,arrayitems,",");
}
{
	map[$2]=$1;
}
END{
	res="";
	for(i=1;i<=length(arrayitems);i++){
		if(map[arrayitems[i]]!=""){
		  res=res""map[arrayitems[i]];
		  if(i<length(arrayitems)){res=res",";}
		}
	}
	print res;
}' $conffilepath`

awk -v sp="$logformatstr" -v its="$items" -v sps="$outputspstr" '
BEGIN{
 fn=length(sp);
 for(i=1;i<=fn;i++){
	list[i]=substr(sp,i,1);
 }
 split(its,rl,",");
}
{
 tstr=$0;
 for(i=1;i<=fn;i++){
	vt=substr(tstr,1);
	end=index(vt,list[i])+1;
	if(end>1){
	    $i=substr(tstr,1,end-2);
	    tstr=substr(tstr,end);
	}else{
	    $i=tstr;
	    tstr="";
	}
  }
  if(length(tstr)>0){
	$i=tstr;
	i++;
  }
  for(i=1;i<=length(rl);i++){
	res=res""$rl[i]""sps;
  } 
  print res;  
  res="";
}' $logfilepath
