local id = ngx.var.arg_topicId
local action = ngx.var.arg_action
local ip = ngx.var.arg_ip
local f = io.popen("awk -F '{if($1==\""..id.."\"&&$2==\""..action.."\"&&$3==\""..ip.."\"){print $4}}' /home/peiliping/dev/linkall/tengine/conf/lua/datafile")
for line in f:lines() do 
  ngx.say(line)
end 
f:close()
