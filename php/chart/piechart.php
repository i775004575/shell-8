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
if(!isset($_GET["tip"])){
$tip = " ";
}else{
$tip = $_GET["tip"];
}

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
		type: 'pie',
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false
            },
            title: {
                text: '<?php echo $title; ?>' ,
                x: -20 //center
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: true,
                        color: '#000000',
                        connectorColor: '#000000',
                        formatter: function() {
                            return '<b>'+ this.point.name +'</b>: '+ this.percentage +' %';
                        }
                    }
                }
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.percentage}%</b>',
            	percentageDecimals: 1
            },
            series: [{ name: '<?php echo $tip; ?>' ,
	    <?php
		echo 'data:[';
		for($i=0;$i<count($sdata);$i++){
			$item = explode("=",$sdata[$i]);
			echo '[\''.$item[0].'\','.$item[1].']';
			if($i!=count($sdata)-1){echo ','; }
		}
		echo ']';
	    ?>
	    }]
        });
    });
    
});
})(jQuery);
</script>
<script src="/test/js/highcharts/highcharts.js"></script>
<script src="/test/js/highcharts/exporting.js"></script>
