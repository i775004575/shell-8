timeout 15 ~/dev/phantomjs/bin/phantomjs v2exlist.js > result

echo "                V2ex ..."

echo "================================================================"

awk -F"\t" '{print NR,$1}' result | more 
