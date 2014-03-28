#!/bin/bash
export LC_ALL=C

username=$1

mysqladmin -u$username -r -i 1 -p extended-status | awk -F"|" "BEGIN{ count=0; }"'
{
if($2 ~ /Variable_name/ && ++count%30 == 1){
    print "----------|---------|----- MySQL Command Status -----|----- Innodb row operation  -----|----- Buffer Pool Read -----|";
    print "---Time---|---QPS---| select  insert  update  delete |   read inserted updated deleted | logical physical cacherate |";
}
else if ($2 ~ /Queries/){queries=$3;}
else if ($2 ~ /Com_select/){com_select=$3;}
else if ($2 ~ /Com_insert/){com_insert=$3;}
else if ($2 ~ /Com_update/){com_update=$3;}
else if ($2 ~ /Com_delete/){com_delete=$3;}
else if ($2 ~ /Innodb_rows_read/){innodb_rows_read=$3;}
else if ($2 ~ /Innodb_rows_deleted/){innodb_rows_deleted=$3;}
else if ($2 ~ /Innodb_rows_inserted/){innodb_rows_inserted=$3;}
else if ($2 ~ /Innodb_rows_updated/){innodb_rows_updated=$3;}
else if ($2 ~ /Innodb_buffer_pool_read_requests/){innodb_lor=$3;}
else if ($2 ~ /Innodb_buffer_pool_reads/){innodb_phr=$3;}
else if ($2 ~ /Uptime / && count >= 2){
  printf(" %s |%8d ",strftime("%H:%M:%S"),queries);
  printf("|%7d %7d %7d %7d ",com_select,com_insert,com_update,com_delete);
  printf("|%7d  %7d %7d %7d ",innodb_rows_read,innodb_rows_inserted,innodb_rows_updated,innodb_rows_deleted);
  if(innodb_lor+innodb_phr>0){rate=(innodb_lor*100/(innodb_lor+innodb_phr));}else{rate=100;}
  printf("|%8d %8d %8d'%' |\n",innodb_lor,innodb_phr,rate);
}}'
