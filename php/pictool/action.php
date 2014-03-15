<?php
if ($_FILES["file"]["error"] > 0){
  echo "Failed: " . $_FILES["file"]["error"];
}

if(isset($_FILES["resize_file"]) && isset($_POST["size"]) && ($_FILES["resize_file"]["type"]=="image/jpeg" ||
 $_FILES["resize_file"]["type"]=="image/png") &&  $_FILES["resize_file"]["size"]< 500*1024 )
{
  $sizestr = $_POST["size"];
  $sizestr = str_replace(" ","",$sizestr );
  $tname = rand(1000,9999).time().md5($_FILES["resize_file"]["name"]);
  move_uploaded_file($_FILES["resize_file"]["tmp_name"],"upload/" . $tname );
  exec('convert -resize '. $sizestr  .' upload/'.$tname .' upload/r-' .$tname  ,$results,$ret);
  echo '<img src="upload/r-' . $tname  . '" />';
}else{
  echo "Invalid File";
}
?>
