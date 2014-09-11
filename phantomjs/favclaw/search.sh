kw=$1
file=$2
gawk  "{IGNORECASE=1}; /^========== .* ==========/{line=\$0;url=\$2;}  /$kw/{if(line!=\$0){print \"------------\"url; print \$0;}}" $2

