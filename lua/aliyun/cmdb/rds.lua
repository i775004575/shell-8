local cjson , aliyunclient ,cache = require "cjson" ,require "aliyunclient" , ngx.shared.rdscache
local method , result = ngx.var.arg_method , {}

function handlePageN(pageNum , result)
	local resultjson = aliyunclient.visitjson('rds' , 'DescribeDBInstances' , ' --PageNumber ' .. pageNum )
	table.foreach(resultjson.data.Items.DBInstance , function(key , val)
		local netinfo = aliyunclient.visitjson('rds' , 'DescribeDBInstanceNetInfo' , '--DBInstanceId ' .. val.DBInstanceId)
		val.DBInstanceNetInfo = netinfo.data.DBInstanceNetInfos.DBInstanceNetInfo
		table.insert(result , val)
	end)
	if (pageNum * resultjson.data.PageRecordCount) < resultjson.data.TotalRecordCount then
		handlePageN(pageNum + 1 , result)
	end
end

if method == 'reload' then
	handlePageN(1 , result)
	cache:set('rds',cjson.encode(result))
elseif method == 'list' then
	local json = cache:get('rds')
	ngx.say(json)
end

