local cjson , aliyunclient ,cache = require "cjson" ,require "aliyunclient" , ngx.shared.rediscache
local method , result = ngx.var.arg_method , {}

function handlePageN(pageNum , result)
	local resultjson = aliyunclient.visitjson('r-kvstore' , 'DescribeInstances' , ' --PageNumber ' .. pageNum )
	table.foreach(resultjson.data.Instances.KVStoreInstance , function(key , val)
		table.insert(result , val)
	end)
	if (pageNum * resultjson.data.PageSize) < resultjson.data.TotalCount then
		handlePageN(pageNum + 1 , result)
	end
end

if method == 'reload' then
	handlePageN(1 , result)
	cache:set('redis',cjson.encode(result))
elseif method == 'list' then
	local json = cache:get('redis')
	ngx.say(json)
end

