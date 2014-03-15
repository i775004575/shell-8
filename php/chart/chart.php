<?php
// the location for chart
if(!isset($_GET["ct"])){
$container = "container";
echo '<div id="'.$container.'"/>' ;
}else{
$container = $_GET["ct"];
}

//title
if(!isset($_GET["ti"])){
$title = "";
}else{
$title = $_GET["ti"];
}

//y title
if(!isset($_GET["yti"])){
$ytitle = "";
}else{
$ytitle = $_GET["yti"];
}

//x value 
if(!isset($_GET["xv"])){
$xvalue = "";
}else{
$xvalue = $_GET["xv"];
$xvalue = substr($xvalue,1,strlen($xvalue)-2);
}

//x data
if(!isset($_GET["data"])){
$data = "";
}else{
$data = $_GET["data"];
$data = substr($data,1,strlen($data)-2);
$sdata = explode(";",$data);
}


?>

<script type="text/javascript" src="/test/js/highcharts/jquery.min.js"></script>
<script type="text/javascript">jQuery.noConflict();</script>
<script type="text/javascript">
(function($){ // encapsulate jQuery
$(function () {
    var chart;
    $(document).ready(function() {
        chart = new Highcharts.Chart({
            chart: {
                renderTo: '<?php echo $container; ?>' ,
                type: 'line',
		zoomType: 'x',
                marginRight: 130,
                marginBottom: 25
            },
            title: {
                text: '<?php echo $title; ?>' ,
                x: -20 //center
            },
            subtitle: {
                text: '',
                x: -20
            },
            xAxis: {
                categories: [ <?php echo $xvalue ; ?> ]
            },
            yAxis: {
                title: {
                    text: '<?php echo $ytitle; ?>'
                },
            plotLines: [{
		    value: 0,
                    width: 1,
                    color: '#808080'
                }]
            },
            tooltip: {
                formatter: function() {
                        return '<b>'+ this.series.name +'</b><br/>'+
                        this.x +': '+ this.y ;
                }
            },
            legend: {
                layout: 'vertical',
                align: 'right',
                verticalAlign: 'top',
                x: -10,
                y: 100,
                borderWidth: 0
            },
            series: [
	    <?php
		for($i=0;$i<count($sdata);$i++){
			$item = explode("=",$sdata[$i]);
			echo '{name:\''.$item[0].'\',data:['.substr($item[1],1,strlen($item[1])-2).']}';
			if($i!=count($sdata)-1){echo ','; }
		}
	    ?>
	    ]
        });
    });
    
});
})(jQuery);
</script>
<script src="/test/js/highcharts/highcharts.js"></script>
<script src="/test/js/highcharts/exporting.js"></script>
<script type="text/javascript" src="/test/js/highcharts/gray.js"></script>
