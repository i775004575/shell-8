#!/bin/bash
export LC_ALL=C

file=$1

awk '
BEGIN{
ready="false";
key="";
}
{
if(ready=="true"&&key!=""&&$0!=""){ 
	rate="";
	start=index($0,"[");
	end=index($0,"]");
	tmprate=substr($0,start,(end-start+1));
	rate=int(substr(tmprate,match(tmprate,/[0-9]+%]/),RLENGTH-2));
	step=substr($0,end+3);
	if(rate>5&&rate<100){
		map[key"~~~"step]++;
		map2[key"~~~"step]+=rate;
	}
}
if($4=="timer.TimerFilter"){
	ready="true";
	key=substr($9,0,index($9,"?")-1);if(key==""){key=$9;}
}
if($0==""){
	ready="false";
	key="";
}
}
END{
	for(t in map){
		if(map[t]>5){
			gsub(/" "/,"",t);
			page=substr(t,0,index(t,"~~~")-1);
			method=substr(t,index(t,"~~~")+3);
			if(length(method)>100){
				method=substr(method,15,95);
			}
			print page"\t"map[t]"\t"int(map2[t]/map[t])"%\t"method;
		}
	}
}' $file | sort -k2nr

