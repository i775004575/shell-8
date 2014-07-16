size=$1
targetfile=$2

awk -v si="$size" '
BEGIN{
 temp="";count=0;
 level=1;
}
{
 if(temp==$1){
  count++;
 }else{
  if(count>level){
    map[level]="";
    level=count;
    map[level]=temp;
  }else if(count==level){
    map[level]=map[level]"_"temp;
  }
  temp=$1;
  count=1;
 }
}
END{
 for(a in map){
   if(map[a]!=""){
    re=map[a];
    split(re,rs,"_");
    for(b in rs){
	print a,rs[b];
    }
   }
 }
}' $targetfile
