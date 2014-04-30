#!/bin/bash

templatepath=$1
propertypath=$2

awk -v pfp="$propertypath" '
	function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
	function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
	function trim(s)  { return rtrim(ltrim(s)); }
	BEGIN{
		while ((getline < pfp) > 0 ) {
			split($0,kvstr,"=");
			key=trim(kvstr[1]);
			value=trim(kvstr[2]);
			if(key!="" && value!=""){
				varmap[key]=value;
			}
		}
		close(pfp)
	} 
	{
		filter="false";
		varname="";
		resultline=""
		line=$0;

		for(i=1;i<=length(line);i++){
			t=substr(line,i,1);
			if(filter=="true"){
				if(t!="}"){
					varname=varname""t;
					if(i==length(line)){
						resultline=resultline""varname;
					}
				}else{
					filter="false";
					resultline=resultline""varmap[varname];
					varname="";
				}
				continue;
			}
			if(filter=="false" && substr(line,i+1,2)=="${"){
				i=i+2;
				if(t=="\\"){
					resultline=resultline"${";
					continue;
				}else{
					filter="true";
				}
			}
			resultline=resultline""t;
		}
		print resultline;
	}  ' $templatepath 