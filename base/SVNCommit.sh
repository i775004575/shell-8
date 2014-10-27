#!/bin/sh

################functions

func(){
flag=$1
mes=$2

t1=`awk -v fl=$flag '{if($1==fl) print $0}' $tmpresult`
if [ "$t1" != "" ] ;then
echo  "==============================="
echo  $mes
echo  ""
awk -v fl=$flag '{if($1==fl) print $0}' $tmpresult
fi
}
################

clear

path=$1
if [ -z "$path" ] ;then
path=`pwd`
fi

appname=`svn info $path | fgrep URL | awk -F"/" '{print $NF}'`
echo  "AppName:" $appname
tmpresult="/tmp/svntempresult"
svn st $path  > $tmpresult

t1=""

func "M" "These files modified will be commit !!!"

func "A" "These files added will be commit !!!"

func "D" "These files deleted will be commit !!!"

func "?" "These files not in svn will not be commit !!!" 

echo  "==============================="
if [ "$t1" != "" ] ;then
echo  "Need add the files not in svn automatically ? (y/n)"
read ans
case $ans in 
y)
   m=`awk '{if($1=="?"){a=$2" "a}}END{print a}' $tmpresult`
   echo  "==========Add Files============"
   for mk in `echo $m`
   do 
	svn add $mk
   done
;;
esac
echo  "==============================="
fi

echo  "Will You Commit? (y/n)"
read  ans
case $ans in 
y|Y|yes|YES)
 echo "Enter Reason For Commit!"
 read reason
 message="Reason: $reason"
 svn ci -m "$message"
 svn up 
;;

n|N|no|NO)
 exit 0
;;
esac
