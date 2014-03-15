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

//xtitle
if(!isset($_GET["xt"])){
$xtitle = "X Value";
}else{
$xtitle = $_GET["xt"];
}

//ytitle
if(!isset($_GET["yt"])){
$ytitle = "Y Value";
}else{
$ytitle = $_GET["yt"];
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
                type: 'scatter',
                zoomType: 'xy'
            },
            title: {
                text: '<?php echo $title; ?>'
            },
            subtitle: {
                text: ''
            },
            xAxis: {
                title: {
                    enabled: true,
                    text: '<?php echo $xtitle; ?>'
                },
                startOnTick: true,
                endOnTick: true,
                showLastLabel: true
            },
            yAxis: {
                title: {
                    text: '<?php echo $ytitle; ?>'
                }
            },
            tooltip: {
                formatter: function() {
                        return ''+
                        this.x +' , '+ this.y +' ';
                }
            },
            legend: {
		enable: false
            },
            plotOptions: {
                scatter: {
                    marker: {
                        radius: 5,
                        states: {
                            hover: {
                                enabled: true,
                                lineColor: 'rgb(100,100,100)'
                            }
                        }
                    },
                    states: {
                        hover: {
                            marker: {
                                enabled: false
                            }
                        }
                    }
                }
            },
            series: [{
                name: 'Data Show',
                color: 'rgba(23, 83, 83, .5)',
                data: [
		     <?php
			for($i=0;$i<count($sdata);$i++){
				$item = explode("=",$sdata[$i]);
				echo '['.$item[0].','.$item[1].']' ;
			if($i!=count($sdata)-1){echo ','; }
			}
		    ?>
		]
            }]
        });
    });
    
});

})(jQuery);
</script>
<script src="/test/js/highcharts/highcharts.js"></script>
<script src="/test/js/highcharts/exporting.js"></script>
