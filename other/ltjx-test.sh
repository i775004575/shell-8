rooturl="/home/peiliping/dev/gitwork/shell/other/"
srcurl=$rooturl"css-src/nt/"
targeturl=${rooturl}`date +%Y%m%d`

if [ -d "$targeturl" ] ; then 
rm -rf ${targeturl}
fi
mkdir $targeturl $targeturl"/c"

cd $srcurl
for filename in `ls *.css` ; do
awk -F" |;|\"" '$1=="@import"{while(getline tmp <$3>0){print tmp;}} $1!="@import"{print $0;}' $filename >${targeturl}"/c/"${filename}
done

cd $targeturl"/c/"
for filename in `ls *.css` ; do
cd $srcurl"c/"
awk -F" |;|\"" '$1=="@import"{while(getline tmp <$3>0){print tmp;}} $1!="@import"{print $0;}' $targeturl"/c/"$filename > $targeturl"/"$filename
done

cd $targeturl
for filename in `ls *.css` ; do
sed -i /\*/d $filename
sed -i -e "s/ *; */;/g"  -e "s/ *{ */{/g" -e "s/ *} */}/g" $filename
cat $filename | tr -d  "\n" | tr -d "\t"  | tr -d "\r" > $filename"-new"
mv $filename"-new" $filename
done
