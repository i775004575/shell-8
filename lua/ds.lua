local name = ngx.var.arg_dynamicdatasourcename
local token = ngx.var.arg_token
local ip = ngx.var.arg_ip
local f = io.popen("awk -F '{if($1==\""..ip.."\"&&$2==\""..token.."\"&&$3==\""..name.."\"){print $4}}' /home/peiliping/dev/linkall/tengine/conf/lua/dsfile")
for line in f:lines() do 
  ngx.say(line)
end 
f:close()
