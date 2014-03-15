<html>
<title>Music World</title>
<head>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8/jquery.min.js"></script>
<script type="text/javascript" src="jPlayer/jquery.jplayer.min.js"></script>
<script type="text/javascript" src="jPlayer/skin/circle.player.js"></script>
<script type="text/javascript" src="jPlayer/skin/mod.csstransforms.min.js"></script>
<script type="text/javascript" src="jPlayer/skin/jquery.grab.js"></script>

<link rel="stylesheet" href="jPlayer/skin/circle.player.css">
<script type="text/javascript">
 $(document).ready(function(){
  var myCirclePlayer = new CirclePlayer("#jquery_jplayer_1",
	{
		<?php
			$name = $_GET["n"];
			echo  'mp3: "http://c2216.orca.io/test/music/mp3/'.$name.'"' ;
		?>
	}, {
		cssSelectorAncestor: "#cp_container_1",
		swfPath: "jPlayer",
		wmode: "window",
		supplied: "mp3"
	});
 });
</script>
</head>
<body>
<div id="jquery_jplayer_1" class="cp-jplayer"></div>
<div id="cp_container_1" class="cp-container">
	<div class="cp-buffer-holder">
		<div class="cp-buffer-1"></div>
		<div class="cp-buffer-2"></div>
	</div>
	<div class="cp-progress-holder">
		<div class="cp-progress-1"></div>
		<div class="cp-progress-2"></div>
	</div>
	<div class="cp-circle-control"></div>
	<ul class="cp-controls">
		<li><a class="cp-play" tabindex="1">play</a></li>
		<li><a class="cp-pause" style="display:none;" tabindex="1">pause</a></li> 
	</ul>
</div>
</body>
</html>
