local t1 = ngx.var.arg_s
local t2 = ngx.var.arg_e
local f = io.popen("tail -1000 /home/peiliping/dev/logs/message.log |awk -F '{$2=$2*1000;if($2>="..t1.."&&$2<"..t2..")print $1,$4,$3}'") 
for line in f:lines() do 
  ngx.say("["..line.."]")
end 
f:close()
