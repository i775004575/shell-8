srcfile=$1
targetfile=$2
size=$3

awk -v si="$size" '
{
 map[NR"_1"]=$1;
 map[NR"_2"]=$2;
 map[NR"_3"]=$3;
 map[NR"_4"]=$4;
}
END{
	for(i1=0;i1<10;i1++){
	 for(i2=0;i2<10;i2++){
	  for(i3=0;i3<10;i3++){
	   for(j1=0;j1<10;j1++){
	    for(j2=0;j2<10;j2++){
             for(j3=0;j3<10;j3++){
	      for(k=0;k<10;k++){
		for(i=1;i<=si;i++){
	           $1=map[i"_1"];
		   $2=map[i"_2"];
		   $3=map[i"_3"];
		   $4=map[i"_4"];
		   r=(($1^i1)*j1 + ($2^i2)*j2 + ($3^i3)*j3 + k)%10;
		   if(r%3 == $4%3){
		    print(i1""i2""i3""j1""j2""j3""k" "i);
		   }
	        }
	      }
	     }
	    }
	   }
	  }
	 }
	}
}' $srcfile > $targetfile
