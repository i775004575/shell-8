#!/bin/bash
export LC_ALL=C

logfilepath=""
logformatstr=""
logformatfile=""

while getopts "f:m:" optname 
do 
    case "$optname" in
    "f")
	logfilepath=$OPTARG
        ;;
    "m")
	logformatfile=$OPTARG
	logformatstr=`awk -F'=' '$1=="format"{print $2}' $logformatfile`
	;;
    esac
done 

awk -v sp="$logformatstr" '
BEGIN{
 fn=length(sp);
 for(i=1;i<=fn;i++){
	list[i]=substr(sp,i,1);
 }
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
  for(k=1;k<=i-1;k++){
	print "$"k"\t----------\t"$k;
  }
  print "********************************************************";
}' $logfilepath
