
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
		action="false";
		actname="";
		resultline=""
		line=$0;

		for(i=1;i<=length(line);i++){
			t=substr(line,i,1);
			if(filter=="true"){
				if(t!="}"){
					varname=varname""t;
					if(i==length(line)){
						resultline=resultline"${"varname;
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
			if(action=="true"){
				if(t!="}"){
					actname=actname""t;
					if(i==length(line)){
						resultline=resultline"#{"actname;
					}
				}else{
					action="false";
					split(actname,ppp,":");
					ppp[2]=trim(ppp[2]);
					if(ppp[2]!="" && substr(ppp[2],0,1)=="^"){
						ppp[2]=varmap[substr(ppp[2],2)];
					}
					resultline=resultline""f_action(trim(ppp[1]),ppp[2]);
					ppp[1]="";ppp[2]="";
					actname="";
				}
				continue;
			}
			if(action=="false" && substr(line,i+1,2)=="#{"){
				i=i+2;
				if(t=="\\"){
					resultline=resultline"#{";
					continue;
				}else{
					action="true";
				}
			}
			resultline=resultline""t;
		}
		print resultline;
	}  
