<?php
  include("mysql.php");
  $key = $_GET["key"];
  $i=kvget($key);
  if(strlen($i)>0){
  echo $i;
  }else{
  echo "not exist";
  }
?>
