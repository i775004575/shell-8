#!/bin/bash

##################################################
##						                                  ##
##    if($2==null) return $1; else return $2	  ##
##            						                      ##
##################################################

getStringWithDefault() {
default=$1
t=$2
if [ -z "$t" ] ;then
t=$default
fi
echo $t
}


##################################################
##                                              ##
##          		extend grep                     ##
##                                              ##
##################################################

cgrep(){
paras=$*
fgrep  $paras --color=auto -i
}

psgrep(){
content=$1
ps axu  | fgrep -v "color=auto"  | cgrep $content 
}


##################################################
##                                              ##
##		          extend  sed                     ##
##                                              ##
##################################################

sedreplace(){
src=$1
tgt=$2
fpath=$3
sed  -i  "s/$src/$tgt/g"  $fpath
}

sedlines(){
from=$1
to=$2
fpath=$3
sed -n "${from},${to}p" $fpath
}


##################################################
##                                              ##
##      	sort | uniq -c | sort -nr             ##
##                                              ##
##################################################

sus(){
fpath=$1
sort $fpath | uniq -c | sort -nr
}



##################################################
##                                              ##
##             		awk join                     	##
##                                              ##
##################################################

awkjoin(){
sep=$1
ia=$2
ib=$3
fap=$4
fbp=$5
all='$0'
awk -F"${sep}" "NR==FNR{map[$ia]=$all;}NR>FNR{map[$ib]=map[$ib] \"\002\" $all;}END{for(line in 
map){print map[line]}}" $fap $fbp
}

##################################################
##                                              ##
##              is numberic                     ##
##                                              ##
##################################################

isnum(){
num=$1
expr ${num} + 0 1>/dev/null 2>&1
if [ $? -eq 0 ]; then
     echo "true"
else
     echo "false"
fi
}

##################################################
##                                              ##
##              cd back                         ##
##                                              ##
##################################################

ccd(){
p=`pwd`
coner=`echo -e $1 | awk -F"/" '{print $1}' `
layer=`echo -e $1 | awk -F"/" 'NF>1{for(i=2;i<NF;i++){ s=s""$i"/"}}END{print s}'`
pr=`echo $p | awk -v var=$coner -F"/" '{for(i=1;i<NF+1;i++){z=z$i""FS;if($i==var){break;}}}END{print z}'`
cd $pr$layer
}

_ccd(){
local path cur dirs ever coner layer fake
_get_comp_words_by_ref cur
ever=`echo $cur | awk -F"/" 'NF>1{ print "true" }'`
if [ -z "$ever" ];then
  path=`pwd`
  dirs=`echo $path | awk -F"/" '{for(i=1;i<NF+1;i++){s=s$i" ";}}END{print s}'`
else
  coner=`echo -e $cur | awk -F"/" '{print $1}' `
  path=`pwd`
  path=`echo -e $path | awk -F"/" -v var=$coner '{for(i=1;i<NF+1;i++){if($i==var){break;}if($i==""){s="/";}else{s=s""$i"/"}}}END{print s}'`
  layer=`echo -e $cur | awk -F"/" 'NF>1{for(i=2;i<NF;i++){ s=s""$i"/"}}END{print s}'`
  dirs=`ls -l $path$coner"/"$layer | grep ^d | awk '{a=a" "$9;}END{print a}' | awk -v v1=$coner"/"$layer '{ for(i=1;i<NF+1;i++){s=s" "v1""$i} } END{print s}' `
fi
dirs="$dirs"
COMPREPLY=( $( compgen -W "$dirs" -S "/" -- "$cur" ) )
}

complete -F _ccd -o nospace ccd

##################################################
##                                              ##
##                time	                        ##
##                                              ##
##################################################

dateconvert2s(){
s=$1
date -d "${s}" +%s
}

second2date(){
s=$1
date --date=@${s} "+%Y-%m-%d %H:%M:%S"
}

datecompare(){
s1=$1
s2=$2
t1=`dateconvert2s $s1`
t2=`dateconvert2s $s2`

if [ $t1 -ge $t2 ];then
  echo "true"
else
  echo "false"
fi
}

##################################################
##                                              ##
##              express? A:B                    ##
##                                              ##
##################################################

aorb(){
r=$1
exr=$2
rt1=$3
rt2=$4
if [ $r = $exr  ];then
  echo $rt1
else
  echo $rt2
fi
}


##################################################
##                                              ##
##              du extend                       ##
##                                              ##
##################################################

zdu(){
dep=$1
path=$2
dw=`getStringWithDefault "-h" $3`
du --max-depth=$dep $path $dw
}

##################################################
##                                              ##
##               for do commond                 ##
##                                              ##
##################################################


fordo(){
commond=$1
trytimes=`getStringWithDefault "100" $2`
sleeptime=`getStringWithDefault "1s" $3`

for i in `seq $trytimes`
do
$commond
sleep $sleeptime
done
}

##################################################
##                                              ##
##               tail files                     ##
##                                              ##
##################################################

tailfiles(){
para=$@
lines=`echo $para | awk '{print "-"$1}'`
para=`echo $para | awk '{for(i=2;i<=NF;i++)r=r" "$i}END{print r}' `
clear
for i in `echo $para`
do
echo ""
echo "========================================="$i"========================================="
echo ""
tail $lines $i
done
}

##################################################
##                                              ##
##                进制转换                       ##
##                                              ##
##################################################
convertnumber(){
num=$1
scale=$2
case $scale in
8)
 echo $num  |awk '{printf "%o\n",$0}'
;;
10)
  echo $num  |awk '{printf "%\n",$0}'
;;
16)
  echo $num  |awk '{printf "%x\n",$0}'
;;
esac
}

##################################################
##                                              ##
##                dstat ex                      ##
##                                              ##
##################################################
dstatex(){
  dstat -tcdmnrspl --top-cpu --top-mem --top-io
}


##################################################
##                                              ##
##                Maven Eclipse                 ##
##                                              ##
##################################################
eclipse(){
  mvn -U eclipse:clean eclipse:eclipse -DdownloadSources=true
}
