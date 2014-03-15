<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>MAP SERVICE</title>
    <link href="js/jquery.vector-map.css" media="screen" rel="stylesheet" type="text/css" />
    <script src="js/jquery-1.6.min.js" type="text/javascript"></script>
    <script src="js/jquery.vector-map.js" type="text/javascript"></script>
    <script src="js/china-zh.js" type="text/javascript" charset="utf-8" /></script>
    <script type="text/javascript">
        $(function () {
            var dataStatus = [
<?php
if(!isset($_GET["data"])){
$sdata = "";
}else{
$data = $_GET["data"];
$data = substr($data,1,strlen($data)-2);
$sdata = explode(";",$data);
}


$idvsname["香港"]="HKG";
$idvsname["海南"]="HAI";
$idvsname["云南"]="YUN";
$idvsname["北京"]="BEJ";
$idvsname["天津"]="TAJ";
$idvsname["新疆"]="XIN";
$idvsname["西藏"]="TIB";
$idvsname["青海"]="QIH";
$idvsname["内蒙古"]="NMG";
$idvsname["宁夏"]="NXA";
$idvsname["山西"]="SHX";
$idvsname["辽宁"]="LIA";
$idvsname["吉林"]="JIL";
$idvsname["黑龙江"]="HLJ";
$idvsname["河北"]="HEB";
$idvsname["山东"]="SHD";
$idvsname["河南"]="HEN";
$idvsname["陕西"]="SHA";
$idvsname["四川"]="SCH";
$idvsname["重庆"]="CHQ";
$idvsname["湖北"]="HUB";
$idvsname["安徽"]="ANH";
$idvsname["江苏"]="JSU";
$idvsname["上海"]="SHH";
$idvsname["浙江"]="ZHJ";
$idvsname["福建"]="FUJ";
$idvsname["台湾"]="TAI";
$idvsname["江西"]="JXI";
$idvsname["湖南"]="HUN";
$idvsname["贵州"]="GUI";
$idvsname["广西"]="GXI";
$idvsname["广东"]="GUD";
$idvsname["甘肃"]="GAN";

for($i=0;$i<count($sdata);$i++){
	$item = explode("=",$sdata[$i]);
	echo '{cha: \''.$idvsname[$item[0]].'\',name: \''.$item[0].'\',des: \''.$item[1].'\'}';
	if($i!=count($sdata)-1){echo ','; }
}



?>

		];
            $('#container').vectorMap({ map: 'china_zh',
                color: "#B4B4B4",
                onLabelShow: function (event, label, code) {
                    $.each(dataStatus, function (i, items) {
                        if (code == items.cha) {
                            label.html(items.name + "   "  + items.des);
                        }
                    });
                }
            })
            $.each(dataStatus, function (i, items) {
                if (items.des >= 10000 && items.des < 100000 ) {
                    var josnStr = "{" + items.cha + ":'#00FF00'}";
                    $('#container').vectorMap('set', 'colors', eval('(' + josnStr + ')'));
                }
		if (items.des >= 100000 && items.des < 300000 ) {
                    var josnStr = "{" + items.cha + ":'#FFA500'}";
                    $('#container').vectorMap('set', 'colors', eval('(' + josnStr + ')'));
                }
		if(items.des >= 300000) {
                  var josnStr = "{" + items.cha + ":'#FF3030'}";
                    $('#container').vectorMap('set', 'colors', eval('(' + josnStr + ')'));
                }

            });
            $('.jvectormap-zoomin').click(); // BIGGER
        });
      
    </script>
</head>
<body>
    <div id="container" style="margin-left: 100px; padding-top: 50px; padding-left: 10px;
        background: white; width: 1024px; height: 768px;">
    </div>
</body>
</html>
