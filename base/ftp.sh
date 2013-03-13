#!/bin/bash

##upload
ftpput () {
filename=$1
localpath=$2
echo "upload ${localpath} to FTP"
ftp -v -n pubftp.taobao.net  << EOF
user pubftp look
binary
hash
put $localpath $filename
bye
EOF
return 1
}

##download
ftpget () { 
filename=$1
localpath=$2
echo "download ${localpath} from FTP"
ftp -v -n pubftp.taobao.net  << EOF
user pubftp look
binary
hash
get  $filename $localpath
bye
EOF
return 1
}


##main

action=$1
localpath=$2
ftpfilename=`echo $localpath | awk -F"/" '{print $NF}'`

case $action in 
1|put)
  ftpput $ftpfilename  $localpath   
;;

2|get)
  ftpget $ftpfilename  $localpath
;;
esac

