clear 

itemnum=$1

url=`awk -F"\t" "NR==$itemnum{print \\$2}" result`

echo "Go To " $url " ......"

awk -F"\t" -v var=$itemnum 'NR==var{print $1}' result

timeout 30 phantomjs v2expage.js $url
