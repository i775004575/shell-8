#!/bin/bash

uid=$1
riqi=$2
tfilename=${1}"-"${2}
favfile=$3

for url in `fgrep "<A" $favfile | awk -F"HREF=\"|\"" '{print $2}' |fgrep  -v "chrome://"`
do
echo "========== "$url" ==========" >> $tfilename
timeout 15 ~/dev/phantomjs/bin/phantomjs singleclaw.js $url >> $tfilename
done
