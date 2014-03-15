<?php
  include("mysql.php");
  $key = $_GET["key"];
  $i=kvput($key,"1");
  echo $i;
?>
