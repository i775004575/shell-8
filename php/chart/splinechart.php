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

if(!isset($_GET["xn"])){
$xname = "";
}else{
$xname = $_GET["xn"];
}


if(!isset($_GET["it"])){
$interval = '1000' ;
}else{
$interval = $_GET["it"];
}

if(!isset($_GET["durl"])){
$dataurl = '1000' ;
}else{
$dataurl = $_GET["durl"];
}


?>

<script type="text/javascript" src="/test/js/highcharts/jquery.min.js"></script>
<script type="text/javascript">jQuery.noConflict();</script>
<script type="text/javascript">
(function($){ // encapsulate jQuery

$(function () {
    $(document).ready(function() {
        Highcharts.setOptions({
            global: {
                useUTC: false
            }
        });
    
        var chart;
        chart = new Highcharts.Chart({
            chart: {
                renderTo: '<?php echo $container; ?>' ,
                type: 'spline',
                marginRight: 10,
                events: {
                    load: function() {
                        // set up the updating of the chart each second
                        var series = this.series[0];
                        setInterval(function() {
			    $.ajax({
                		url : '<?php echo $dataurl; ?>',
		                cache : false, 
		                async : true,
                		type : "GET",
		                dataType : 'json',
                		success : function (result){
		                    var x = (new Date()).getTime(), // current time
	                                y = result.r;
        	                    series.addPoint([x, y], true, true);
                		}
		            });
                        }, <?php echo $interval; ?> );
                    }
                }
            },
            title: {
                text: '<?php echo $title; ?>'
            },
            xAxis: {
                type: 'datetime',
                tickPixelInterval: 150
            },
            yAxis: {
                title: {
                    text: 'Value'
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
                        Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) +'<br/>'+
                        Highcharts.numberFormat(this.y, 2);
                }
            },
            legend: {
                enabled: false
            },
            exporting: {
                enabled: false
            },
            series: [{
                name: '<?php echo $xname; ?>',
                data: (function() {
                    // generate an array of random data
                    var data = [],
                        time = (new Date()).getTime(),
                        i;
		    for (i = -20; i <= 0; i++) {
                        data.push({
                            x: time + i *  <?php echo $interval; ?> ,
                            y: 0
                        });
                    }
                    return data;
                })()
            }]
        });
    });
    
});

})(jQuery);

</script>
<script src="/test/js/highcharts/highcharts.js"></script>
<script src="/test/js/highcharts/exporting.js"></script>
<script type="text/javascript" src="/test/js/highcharts/gray.js"></script>
