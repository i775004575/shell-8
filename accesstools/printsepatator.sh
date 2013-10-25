logformatfile=$1

logformatstr=`awk -F'=' '$1=="format"{print $2}' $logformatfile`

echo "$logformatstr" | awk '
{
 fn=length($0);
 for(i=1;i<=fn;i++){
	gg=substr($0,i,1);
	if(gg==" "){gg="空格";}
	if(gg=="\t"){gg="tab";}
	printf("%s%s\t%s %s\n","$",i,"----------",gg);
 }
}'
