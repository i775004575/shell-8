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
                type: 'column'
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
                min: 0,
		title: {
                    text: '<?php echo $ytitle; ?>'
                }
            },
	    plotOptions: {
                column: {
                    pointPadding: 0.2,
                    borderWidth: 0
                }
            },
            tooltip: {
                formatter: function() {
                        return '<b>'+ this.series.name +'</b><br/>'+
                        this.x +': '+ this.y ;
                }
            },
            legend: {
                layout: 'vertical',
                align: 'left',
                verticalAlign: 'top',
                x: 100,
                y: 70,
                floating: true,
		backgroundColor: '#FFFFFF',
                shadow: true
            },
	    credits: {
                enabled: false
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
