#!/bin/sh

clear
svnURL=`svn info | fgrep URL | awk -F"URL:" '{print $2}'`
appname=`svn info | fgrep URL | awk -F"/" '{print $NF}'`

echo  "AppName:" $appname

tmpresult="/tmp/svntempresult"
svn st > $tmpresult

t1=`awk '{if($1=="M") print $0}' $tmpresult`
if [ "$t1" != "" ] ;then
echo  "==============================="
echo  "These files modified will be commit!!!"
echo  ""
awk '{if($1=="M") print $0}' $tmpresult
fi

t1=`awk '{if($1=="A") print $0}' $tmpresult`
if [ "$t1" != "" ] ;then
echo  "==============================="
echo  "These files added will be commit"
echo  ""
awk '{if($1=="A") print $0}' $tmpresult
fi

t1=`awk '{if($1=="D") print $0}' $tmpresult`
if [ "$t1" != "" ] ;then
echo  "==============================="
echo  "These files deleted will be commit"
echo  ""
awk '{if($1=="D") print $0}' $tmpresult
fi

t1=`awk '{if($1=="?") print $0}' $tmpresult`
if [ "$t1" != "" ] ;then
echo  "==============================="
echo  "These files not in svn will not be commit"
echo  ""
awk '{if($1=="?") print $0}' $tmpresult
fi

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
 echo "Who Review This Commit"
 read review
 message="Reason: $reason	Reviewer: $review"
 svn ci -m "$message"
 svn up 
;;

n|N|no|NO)
 exit 0
;;
esac
