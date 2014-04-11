local cjson = require "cjson"

local method_name = ngx.var.arg_method
if method_name == "metric_data" then 
	ngx.say(method_name)
else
	ngx.say(cjson.encode( { true, { foo = "bar" } ,{ "a", "b", "c"}}))
end
