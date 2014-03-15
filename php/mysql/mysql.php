<?php

function kvget($key){

  if(!strlen(trim($key))){
    die("key is blank");
  }

  $con=connect();
  $query="select v from kv where k='".$key."'";
  $result=mysql_query($query);
  mysql_close($con);
  $item="";
  while($row=mysql_fetch_array($result)){
    $item=$row['v'];
  }
  return $item;
}

function kvput($key,$value){

  if(!strlen(trim($key))||!strlen(trim($value))){
    die("params is blank");
  }

  $con=connect();
  $sql="insert into kv (k,v,version) values( '".$key."','" .$value."','0')";
  $result=mysql_query($sql);

  mysql_close($con);
  return $result?"true":"false";
}

function connect(){

  $db_host="localhost";
  $db_username="xxxxxxxx";
  $db_password="xxxxxxxx";
  $db_database="test";

  $con = mysql_connect($db_host,$db_username,$db_password);
  mysql_query("set names 'utf8'");
  if (!$con){
    die('Could not connect: ' . mysql_error());
  }

  $db_select=mysql_select_db($db_database);
  if(!$db_select){
    die("could not to the database</br>".mysql_error());
  }

  return $con;
}

?>
